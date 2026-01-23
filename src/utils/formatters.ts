// Formatting utility functions

/**
 * Formats a VIN with spaces for readability (e.g., WBA DT 634 52 CZ 123 45)
 */
export function formatVinDisplay(vin: string): string {
  if (vin.length !== 17) return vin;

  return `${vin.slice(0, 3)} ${vin.slice(3, 5)} ${vin.slice(5, 8)} ${vin.slice(8, 10)} ${vin.slice(10, 12)} ${vin.slice(12, 15)} ${vin.slice(15, 17)}`;
}

/**
 * Formats currency for display
 */
export function formatCurrency(amount: number, currency = 'USD'): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(amount);
}

/**
 * Formats a date for display
 */
export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  }).format(d);
}
