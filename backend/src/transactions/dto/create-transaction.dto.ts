import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MinLength,
} from 'class-validator';

export enum TransactionTypeDto {
  INCOME = 'income',
  EXPENSE = 'expense',
}

export class CreateTransactionDto {
  @ApiProperty({ example: 'Supermercado' })
  @IsString()
  @MinLength(1)
  title: string;

  @ApiProperty({ example: 150.5 })
  @IsNumber()
  @Min(0.01)
  amount: number;

  @ApiProperty({ enum: TransactionTypeDto })
  @IsEnum(TransactionTypeDto)
  type: TransactionTypeDto;

  @ApiProperty({ example: 'Alimentação' })
  @IsString()
  category: string;

  @ApiPropertyOptional({ example: 'Compras da semana' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: '2026-06-01T12:00:00.000Z' })
  @IsDateString()
  date: string;
}
