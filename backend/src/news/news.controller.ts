import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { NewsService } from './news.service';

@ApiTags('news')
@Controller()
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @Get('financial-news')
  @ApiOperation({ summary: 'Notícias financeiras' })
  getFinancialNews() {
    return this.newsService.getFinancialNews();
  }
}
