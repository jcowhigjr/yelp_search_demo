import React from 'react';
import { Page } from '../App';

interface FooterProps {
  setCurrentPage: (page: Page) => void;
}

export function Footer({ setCurrentPage }: FooterProps) {
  return (
    <footer 
      className="mt-auto py-8"
      style={{ 
        backgroundColor: 'var(--color-bg)',
        borderTop: '1px solid var(--color-border)'
      }}
    >
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center gap-4">
          <p style={{ color: 'var(--color-text)', opacity: 0.7 }}>
            © 2025 Coffee Finder
          </p>
          
          <ul className="flex items-center gap-6">
            <li>
              <button
                onClick={() => setCurrentPage('search')}
                className="language-nav__link"
              >
                About
              </button>
            </li>
            <li>
              <button
                onClick={() => setCurrentPage('search')}
                className="language-nav__link"
              >
                Contact
              </button>
            </li>
            <li>
              <button
                onClick={() => setCurrentPage('search')}
                className="language-nav__link"
              >
                Privacy
              </button>
            </li>
          </ul>
        </div>
      </div>

      <style jsx>{`
        .language-nav__link {
          color: var(--color-text);
          opacity: 0.7;
          text-decoration: none;
          transition: opacity 0.2s;
          font-size: 14px;
        }
        
        .language-nav__link:hover {
          opacity: 1;
          text-decoration: underline;
        }
      `}</style>
    </footer>
  );
}
