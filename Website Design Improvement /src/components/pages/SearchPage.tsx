import React, { useState } from 'react';
import { Page } from '../../App';
import { Search } from 'lucide-react';

interface SearchPageProps {
  setCurrentPage: (page: Page) => void;
}

export function SearchPage({ setCurrentPage }: SearchPageProps) {
  const [query, setQuery] = useState('');

  const handleSearch = () => {
    if (query.trim()) {
      setCurrentPage('results');
    }
  };

  return (
    <div style={{ 
      minHeight: 'calc(100vh - 80px)',
      display: 'flex',
      flexDirection: 'column',
      padding: '20px',
      maxWidth: '600px',
      margin: '0 auto'
    }}>
      {/* Header - minimal */}
      <div style={{ textAlign: 'center', marginTop: '40px', marginBottom: '30px' }}>
        <h1 style={{ 
          color: 'var(--color-text)', 
          fontSize: '36px',
          margin: '0 0 12px 0',
          lineHeight: '1.2'
        }}>
          What are you looking for?
        </h1>
        <p style={{ 
          color: 'var(--color-text)', 
          opacity: 0.6,
          fontSize: '18px',
          margin: 0
        }}>
          Coffee, pizza, tacos...
        </p>
      </div>

      {/* Search input - large and prominent */}
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Coffee near me"
          style={{ 
            width: '100%',
            height: '56px',
            fontSize: '20px',
            padding: '0 20px',
            borderRadius: '12px',
            border: '2px solid var(--color-border)',
            backgroundColor: 'var(--color-bg)',
            color: 'var(--color-text)',
            outline: 'none'
          }}
        />
      </div>

      {/* Spacer to push button to bottom */}
      <div style={{ flex: 1 }} />

      {/* Giant search button - fixed at bottom of viewport, above nav */}
      <div style={{ 
        position: 'fixed',
        bottom: '96px',
        left: '20px',
        right: '20px',
        maxWidth: '560px',
        margin: '0 auto'
      }}>
        <button
          onClick={handleSearch}
          disabled={!query.trim()}
          className="flex items-center justify-center gap-3 w-full transition-all"
          style={{
            backgroundColor: query.trim() ? 'var(--color-button-blue)' : '#ccc',
            color: 'white',
            border: 'none',
            borderRadius: '16px',
            height: '64px',
            fontSize: '24px',
            fontWeight: 600,
            cursor: query.trim() ? 'pointer' : 'not-allowed',
            boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
            opacity: query.trim() ? 1 : 0.5
          }}
        >
          <Search className="w-7 h-7" />
          <span>Find Places</span>
        </button>
      </div>
    </div>
  );
}
