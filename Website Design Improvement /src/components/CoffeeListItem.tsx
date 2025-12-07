import React from 'react';
import { Button } from './ui/button';

interface CoffeeShop {
  id: number;
  name: string;
  distance: string;
  address: string;
  phone: string;
  image: string;
}

interface CoffeeListItemProps {
  shop: CoffeeShop;
}

export function CoffeeListItem({ shop }: CoffeeListItemProps) {
  return (
    <div className="bg-white rounded-lg p-6 shadow-sm hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          <h3 className="text-green-800 mb-2">{shop.name.toUpperCase()}</h3>
          <p className="text-gray-400 text-sm mb-3">{shop.distance}</p>
          <div className="space-y-1">
            <p className="text-gray-600 text-sm">{shop.address}</p>
            <p className="text-gray-600 text-sm">{shop.phone}</p>
          </div>
        </div>
        <Button className="bg-blue-600 hover:bg-blue-700 shrink-0">
          View Details
        </Button>
      </div>
    </div>
  );
}
