import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { SaleService } from '../contract/api/sale.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App implements OnInit {
  private readonly saleService = inject(SaleService);

  protected readonly title = signal('frontend');
  protected readonly saleApiStatus = signal<string>('Loading...');
  protected readonly saleApiError = signal<string | null>(null);

  ngOnInit(): void {
    this.callSaleApi();
  }

  private callSaleApi(): void {
    this.saleService.apiSaleHealthGet().subscribe({
      next: (response) => {
        console.log('Sale API Health Response:', response);
        this.saleApiStatus.set(response?.status ?? 'Healthy');
        this.saleApiError.set(null);
      },
      error: (error) => {
        console.error('Sale API Error:', error);
        this.saleApiStatus.set('Error');
        this.saleApiError.set(error.message || 'Failed to connect to Sale API');
      }
    });
  }
}
