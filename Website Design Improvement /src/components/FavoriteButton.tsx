import React, { useState } from 'react';
import { Heart } from 'lucide-react';

interface FavoriteButtonProps {
  isFavorited?: boolean;
  onToggle?: () => void;
  className?: string;
}

export function FavoriteButton({ 
  isFavorited: initialFavorited = false, 
  onToggle,
  className = '' 
}: FavoriteButtonProps) {
  const [isFavorited, setIsFavorited] = useState(initialFavorited);

  const handleClick = () => {
    setIsFavorited(!isFavorited);
    onToggle?.();
  };

  return (
    <button
      onClick={handleClick}
      className={`favorite-btn inline-flex items-center space-x-1 ${className}`}
      aria-label={isFavorited ? 'Remove from favorites' : 'Add to favorites'}
    >
      <Heart 
        className="w-6 h-6"
        fill={isFavorited ? 'var(--color-yelp)' : 'none'}
        style={{ 
          color: isFavorited ? 'var(--color-yelp)' : 'var(--color-text)',
          stroke: isFavorited ? 'var(--color-yelp)' : 'var(--color-text)'
        }}
      />
      <span className="sr-only">
        {isFavorited ? 'Remove from favorites' : 'Add to favorites'}
      </span>

      <style jsx>{`
        .favorite-btn {
          font-size: 24px;
          padding: 8px;
          border-radius: 50%;
          background: transparent;
          border: none;
          cursor: pointer;
          transition: all 0.2s ease;
        }

        .favorite-btn:hover {
          transform: scale(1.1);
          background: rgba(128, 128, 128, 0.1);
        }

        .favorite-btn:active {
          transform: scale(0.95);
        }

        .sr-only {
          position: absolute;
          width: 1px;
          height: 1px;
          padding: 0;
          margin: -1px;
          overflow: hidden;
          clip: rect(0, 0, 0, 0);
          white-space: nowrap;
          border-width: 0;
        }

        .space-x-1 > * + * {
          margin-left: 0.25rem;
        }
      `}</style>
    </button>
  );
}
