import React from 'react';
import { Page } from '../../App';
import { Phone, Navigation, Star, MapPin, Clock, ChevronLeft } from 'lucide-react';
import { coffeeShops } from '../../data/coffeeShops';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface DetailPageProps {
  shopId: number;
  setCurrentPage: (page: Page) => void;
}

export function DetailPage({ shopId, setCurrentPage }: DetailPageProps) {
  const shop = coffeeShops.find(s => s.id === shopId);

  if (!shop) {
    return <div>Shop not found</div>;
  }

  const handleCall = () => {
    window.location.href = `tel:${shop.phone.replace(/\D/g, '')}`;
  };

  const handleDirections = () => {
    const address = encodeURIComponent(shop.address);
    window.location.href = `https://maps.google.com/?q=${address}`;
  };

  return (
    <div style={{ 
      minHeight: 'calc(100vh - 80px)',
      paddingBottom: '140px'
    }}>
      {/* Back button */}
      <div style={{ 
        padding: '16px 20px',
        borderBottom: '1px solid var(--color-border)',
        backgroundColor: 'var(--color-bg)'
      }}>
        <button
          onClick={() => setCurrentPage('results')}
          className="flex items-center gap-2"
          style={{
            background: 'none',
            border: 'none',
            color: 'var(--color-primary)',
            fontSize: '18px',
            cursor: 'pointer',
            padding: '8px 0'
          }}
        >
          <ChevronLeft className="w-6 h-6" />
          <span>Back</span>
        </button>
      </div>

      <div style={{ maxWidth: '600px', margin: '0 auto' }}>
        {/* Image */}
        <div style={{ width: '100%', height: '250px', overflow: 'hidden', backgroundColor: '#f0f0f0' }}>
          <ImageWithFallback
            src={shop.image}
            alt={shop.name}
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        </div>

        {/* Content */}
        <div style={{ padding: '20px' }}>
          {/* Name and rating */}
          <h1 style={{ 
            color: 'var(--color-text)',
            fontSize: '32px',
            margin: '0 0 12px 0',
            lineHeight: '1.2'
          }}>
            {shop.name}
          </h1>

          {/* Rating */}
          <div className="flex items-center gap-2" style={{ marginBottom: '8px' }}>
            <div className="flex items-center">
              {[...Array(5)].map((_, i) => (
                <Star
                  key={i}
                  className="w-5 h-5"
                  fill={i < Math.floor(shop.rating || 0) ? '#FFD700' : 'none'}
                  style={{ 
                    color: i < Math.floor(shop.rating || 0) ? '#FFD700' : '#ccc'
                  }}
                />
              ))}
            </div>
            <span style={{ color: 'var(--color-text)', fontSize: '18px' }}>
              {shop.rating} ({shop.reviews} reviews)
            </span>
          </div>

          {/* Distance */}
          <p style={{ 
            color: 'var(--color-text)', 
            opacity: 0.7,
            fontSize: '20px',
            margin: '0 0 24px 0',
            fontWeight: 600
          }}>
            {shop.distance}
          </p>

          {/* Essential info only */}
          <div style={{ 
            backgroundColor: 'color-mix(in srgb, var(--color-primary) 5%, transparent)',
            borderRadius: '12px',
            padding: '16px',
            marginBottom: '20px'
          }}>
            <div className="flex items-start gap-3" style={{ marginBottom: '12px' }}>
              <MapPin className="w-6 h-6 flex-shrink-0" style={{ color: 'var(--color-primary)', marginTop: '2px' }} />
              <p style={{ color: 'var(--color-text)', fontSize: '16px', margin: 0 }}>
                {shop.address}
              </p>
            </div>

            <div className="flex items-center gap-3" style={{ marginBottom: '12px' }}>
              <Phone className="w-6 h-6 flex-shrink-0" style={{ color: 'var(--color-primary)' }} />
              <p style={{ color: 'var(--color-text)', fontSize: '18px', margin: 0, fontWeight: 600 }}>
                {shop.phone}
              </p>
            </div>

            <div className="flex items-center gap-3">
              <Clock className="w-6 h-6 flex-shrink-0" style={{ color: 'var(--color-primary)' }} />
              <p style={{ color: 'var(--color-text)', fontSize: '16px', margin: 0 }}>
                {shop.hours}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Fixed action buttons - in thumb zone */}
      <div style={{ 
        position: 'fixed',
        bottom: '80px',
        left: 0,
        right: 0,
        padding: '16px 20px',
        backgroundColor: 'var(--color-bg)',
        borderTop: '2px solid var(--color-border)',
        boxShadow: '0 -4px 12px rgba(0,0,0,0.1)'
      }}>
        <div style={{ maxWidth: '600px', margin: '0 auto' }}>
          <div className="flex gap-3">
            {/* Call button - primary action */}
            <button
              onClick={handleCall}
              className="flex items-center justify-center gap-2 transition-all"
              style={{
                flex: 1.2,
                backgroundColor: 'var(--color-button-blue)',
                color: 'white',
                border: 'none',
                borderRadius: '12px',
                height: '60px',
                fontSize: '20px',
                fontWeight: 600,
                cursor: 'pointer',
                boxShadow: '0 2px 8px rgba(0,0,0,0.15)'
              }}
            >
              <Phone className="w-6 h-6" />
              <span>Call Now</span>
            </button>

            {/* Directions button */}
            <button
              onClick={handleDirections}
              className="flex items-center justify-center gap-2 transition-all"
              style={{
                flex: 1,
                backgroundColor: 'var(--color-primary)',
                color: 'white',
                border: 'none',
                borderRadius: '12px',
                height: '60px',
                fontSize: '18px',
                fontWeight: 600,
                cursor: 'pointer',
                boxShadow: '0 2px 8px rgba(0,0,0,0.15)'
              }}
            >
              <Navigation className="w-5 h-5" />
              <span>Directions</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
