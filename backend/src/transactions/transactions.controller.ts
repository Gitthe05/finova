import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { UpdateTransactionDto } from './dto/update-transaction.dto';
import { TransactionsService } from './transactions.service';

@ApiTags('transactions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('transactions')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Get()
  @ApiOperation({ summary: 'Listar transações' })
  @ApiQuery({ name: 'month', required: false, example: '2026-06' })
  @ApiQuery({ name: 'type', required: false })
  @ApiQuery({ name: 'category', required: false })
  findAll(
    @Req() req: { user: { id: string } },
    @Query('month') month?: string,
    @Query('type') type?: string,
    @Query('category') category?: string,
  ) {
    return this.transactionsService.findAll(
      req.user.id,
      month,
      type,
      category,
    );
  }

  @Get('summary')
  @ApiOperation({ summary: 'Resumo financeiro' })
  @ApiQuery({ name: 'month', required: false })
  summary(
    @Req() req: { user: { id: string } },
    @Query('month') month?: string,
  ) {
    return this.transactionsService.summary(req.user.id, month);
  }

  @Post()
  @ApiOperation({ summary: 'Criar transação' })
  create(
    @Req() req: { user: { id: string } },
    @Body() dto: CreateTransactionDto,
  ) {
    return this.transactionsService.create(req.user.id, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar transação' })
  update(
    @Req() req: { user: { id: string } },
    @Param('id') id: string,
    @Body() dto: UpdateTransactionDto,
  ) {
    return this.transactionsService.update(req.user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir transação' })
  remove(@Req() req: { user: { id: string } }, @Param('id') id: string) {
    return this.transactionsService.remove(req.user.id, id);
  }
}
