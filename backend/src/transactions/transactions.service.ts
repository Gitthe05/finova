import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';

const TX_SELECT = {
  id: true,
  userId: true,
  title: true,
  amount: true,
  type: true,
  category: true,
  description: true,
  date: true,
  createdAt: true,
  updatedAt: true,
} as const;

function mapTransaction(row: {
  id: string;
  userId: string;
  title: string;
  amount: Prisma.Decimal;
  type: string;
  category: string;
  description: string | null;
  date: Date;
  createdAt: Date;
  updatedAt: Date;
}) {
  return {
    ...row,
    amount: Number(row.amount),
  };
}

@Injectable()
export class TransactionsService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(userId: string, month?: string, type?: string, category?: string) {
    const where: Prisma.TransactionWhereInput = { userId };
    if (type) where.type = type;
    if (category) where.category = category;
    if (month) {
      const [year, m] = month.split('-').map(Number);
      const start = new Date(year, m - 1, 1);
      const end = new Date(year, m, 0, 23, 59, 59, 999);
      where.date = { gte: start, lte: end };
    }
    return this.prisma.transaction
      .findMany({
        where,
        select: TX_SELECT,
        orderBy: { date: 'desc' },
      })
      .then((rows) => rows.map(mapTransaction));
  }

  async create(userId: string, dto: CreateTransactionDto) {
    const row = await this.prisma.transaction.create({
      data: {
        userId,
        title: dto.title.trim(),
        amount: dto.amount,
        type: dto.type,
        category: dto.category,
        description: dto.description?.trim(),
        date: new Date(dto.date),
      },
      select: TX_SELECT,
    });
    return mapTransaction(row);
  }

  async update(userId: string, id: string, dto: UpdateTransactionDto) {
    await this.ensureOwned(userId, id);
    const row = await this.prisma.transaction.update({
      where: { id },
      data: {
        ...(dto.title !== undefined && { title: dto.title.trim() }),
        ...(dto.amount !== undefined && { amount: dto.amount }),
        ...(dto.type !== undefined && { type: dto.type }),
        ...(dto.category !== undefined && { category: dto.category }),
        ...(dto.description !== undefined && {
          description: dto.description?.trim(),
        }),
        ...(dto.date !== undefined && { date: new Date(dto.date) }),
      },
      select: TX_SELECT,
    });
    return mapTransaction(row);
  }

  async remove(userId: string, id: string) {
    await this.ensureOwned(userId, id);
    await this.prisma.transaction.delete({ where: { id } });
    return { deleted: true };
  }

  async summary(userId: string, month?: string) {
    const where: Prisma.TransactionWhereInput = { userId };
    if (month) {
      const [year, m] = month.split('-').map(Number);
      const start = new Date(year, m - 1, 1);
      const end = new Date(year, m, 0, 23, 59, 59, 999);
      where.date = { gte: start, lte: end };
    }
    const rows = await this.prisma.transaction.findMany({
      where,
      select: { amount: true, type: true },
    });
    let income = 0;
    let expense = 0;
    for (const r of rows) {
      const v = Number(r.amount);
      if (r.type === 'income') income += v;
      else expense += v;
    }
    return {
      income,
      expense,
      balance: income - expense,
      count: rows.length,
    };
  }

  private async ensureOwned(userId: string, id: string) {
    const tx = await this.prisma.transaction.findFirst({
      where: { id, userId },
    });
    if (!tx) throw new NotFoundException('Transação não encontrada');
  }
}
