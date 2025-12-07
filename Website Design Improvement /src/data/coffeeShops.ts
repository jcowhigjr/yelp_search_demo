export interface CoffeeShop {
  id: number;
  name: string;
  distance: string;
  address: string;
  phone: string;
  image: string;
  isFavorited?: boolean;
  rating?: number;
  reviews?: number;
  hours?: string;
  description?: string;
}

export const coffeeShops: CoffeeShop[] = [
  {
    id: 1,
    name: 'Con Leche',
    distance: '0.2 mi away',
    address: '181 Flat Shoals Ave, Atlanta, GA',
    phone: '(555) 123-4567',
    image: 'https://images.unsplash.com/photo-1523368749929-6b2bf370dbf8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBzaG9wJTIwZXh0ZXJpb3J8ZW58MXx8fHwxNzYzNzcyOTYwfDA&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: false,
    rating: 4.5,
    reviews: 128,
    hours: '7:00 AM - 8:00 PM',
    description: 'Cozy neighborhood coffee shop with Latin-inspired drinks and pastries. Known for their signature con leche and homemade empanadas.'
  },
  {
    id: 2,
    name: 'Academy Coffee ATL',
    distance: '0.3 mi away',
    address: '123 Main St, Atlanta, GA',
    phone: '(555) 234-5678',
    image: 'https://images.unsplash.com/photo-1635090976010-d3f6dfbb1bac?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBjdXAlMjBsYXR0ZXxlbnwxfHx8fDE3NjM3NTMwNzl8MA&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: true,
    rating: 4.8,
    reviews: 256,
    hours: '6:30 AM - 9:00 PM',
    description: 'Specialty coffee roaster offering single-origin beans and expert pour-overs. A favorite among coffee enthusiasts.'
  },
  {
    id: 3,
    name: 'Blue Bottle Coffee',
    distance: '0.5 mi away',
    address: '456 Oak Ave, Atlanta, GA',
    phone: '(555) 345-6789',
    image: 'https://images.unsplash.com/photo-1642647916334-82e513d9cc48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBpbnRlcmlvciUyMGNhZmV8ZW58MXx8fHwxNzYzNzcyOTYxfDA&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: false,
    rating: 4.6,
    reviews: 189,
    hours: '7:00 AM - 7:00 PM',
    description: 'Modern minimalist cafe serving freshly roasted coffee. Clean aesthetic and quality-focused approach to coffee.'
  },
  {
    id: 4,
    name: 'Starbucks Reserve',
    distance: '0.7 mi away',
    address: '789 Pine Rd, Atlanta, GA',
    phone: '(555) 456-7890',
    image: 'https://images.unsplash.com/photo-1607618421926-b72c6a99c342?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxlc3ByZXNzbyUyMG1hY2hpbmUlMjBiYXJpc3RhfGVufDF8fHx8MTc2Mzc3Mjk2MXww&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: false,
    rating: 4.3,
    reviews: 342,
    hours: '6:00 AM - 10:00 PM',
    description: 'Premium Starbucks location featuring rare single-origin coffees and craft cocktails. Elevated coffee experience.'
  },
  {
    id: 5,
    name: 'The Daily Grind',
    distance: '1.0 mi away',
    address: '321 Elm St, Atlanta, GA',
    phone: '(555) 567-8901',
    image: 'https://images.unsplash.com/photo-1672570050756-4f1953bde478?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb2ZmZWUlMjBiZWFucyUyMHJvYXN0ZWR8ZW58MXx8fHwxNzYzNzY0OTAyfDA&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: true,
    rating: 4.7,
    reviews: 215,
    hours: '7:00 AM - 8:00 PM',
    description: 'Local favorite serving hearty breakfast sandwiches and strong coffee. Perfect spot for remote work and meetings.'
  },
  {
    id: 6,
    name: 'Brew & Co',
    distance: '1.2 mi away',
    address: '654 Maple Dr, Atlanta, GA',
    phone: '(555) 678-9012',
    image: 'https://images.unsplash.com/photo-1563463904828-5bd5938200a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjYWZlJTIwc3RvcmVmcm9udCUyMHdpbmRvd3xlbnwxfHx8fDE3NjM3NzI5NjJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    isFavorited: false,
    rating: 4.4,
    reviews: 167,
    hours: '6:30 AM - 9:00 PM',
    description: 'Charming corner cafe with outdoor seating and homemade pastries. Great atmosphere for studying or casual meetups.'
  }
];
