import React from 'react';
import { MapPin, Phone } from 'lucide-react';
import { Button } from './ui/button';
import { ImageWithFallback } from './figma/ImageWithFallback';

interface CoffeeShop {
  id: number;
  name: string;
  distance: string;
  address: string;
  phone: string;
  image: string;
}

interface CoffeeCardProps {
  shop: CoffeeShop;
}

export function CoffeeCard({ shop }: CoffeeCardProps) {
  return (
    <div className="bg-white rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow">
      <div className="aspect-video w-full overflow-hidden bg-gray-200">
        <ImageWithFallback
          src={`https://source.unsplash.com/800x600/?${encodeURIComponent(shop.image)}`}
          alt={shop.name}
          className="w-full h-full object-cover"
        />
      </div>
      <div className="p-4">
        <h3 className="mb-2">{shop.name}</h3>
        <p className="text-gray-500 text-sm mb-3">{shop.distance}</p>
        
        <div className="space-y-2 mb-4">
          <div className="flex items-start gap-2 text-sm">
            <MapPin className="w-4 h-4 text-orange-500 mt-0.5 flex-shrink-0" />
            <span className="text-gray-600">{shop.address}</span>
          </div>
          <div className="flex items-center gap-2 text-sm">
            <Phone className="w-4 h-4 text-orange-500 flex-shrink-0" />
            <span className="text-gray-600">{shop.phone}</span>
          </div>
        </div>
        
        <Button className="w-full bg-blue-600 hover:bg-blue-700">
          MORE INFO
        </Button>
      </div>
    </div>
  );
}
