import React from 'react';
import { Page } from '../App';
import { Home, Heart, User, Moon, Sun } from 'lucide-react';

interface NavigationProps {
  currentPage: Page;
  setCurrentPage: (page: Page) => void;
  isLoggedIn: boolean;
  onLogout: () => void;
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

export function Navigation({ currentPage, setCurrentPage, isLoggedIn, theme, toggleTheme }: NavigationProps) {
  const navItems = [
    { page: 'search' as Page, icon: Home, label: 'Search' },
    { page: 'favorites' as Page, icon: Heart, label: 'Favorites', requiresAuth: true },
    { page: 'login' as Page, icon: User, label: isLoggedIn ? 'Account' : 'Login' },
  ];

  return (
    <nav 
      className="fixed bottom-0 left-0 right-0 z-50 shadow-lg"
      style={{ 
        backgroundColor: 'var(--color-bg)',
        borderTop: '2px solid var(--color-border)'
      }}
    >
      <div className="flex items-center justify-around" style={{ height: '80px', maxWidth: '600px', margin: '0 auto' }}>
        {navItems.map(({ page, icon: Icon, label, requiresAuth }) => {
          if (requiresAuth && !isLoggedIn) return null;
          
          const isActive = currentPage === page;
          
          return (
            <button
              key={page}
              onClick={() => setCurrentPage(page)}
              className="flex flex-col items-center justify-center gap-1 transition-all"
              style={{
                color: isActive ? 'var(--color-primary)' : 'var(--color-text)',
                opacity: isActive ? 1 : 0.6,
                padding: '8px 16px',
                minWidth: '80px',
                minHeight: '64px'
              }}
            >
              <Icon className="w-7 h-7" strokeWidth={isActive ? 2.5 : 2} />
              <span style={{ fontSize: '12px', fontWeight: isActive ? 600 : 400 }}>
                {label}
              </span>
            </button>
          );
        })}
        
        {/* Theme toggle */}
        <button
          onClick={toggleTheme}
          className="flex flex-col items-center justify-center gap-1 transition-all"
          style={{
            color: 'var(--color-text)',
            opacity: 0.6,
            padding: '8px 16px',
            minWidth: '80px',
            minHeight: '64px'
          }}
        >
          {theme === 'light' ? <Moon className="w-7 h-7" /> : <Sun className="w-7 h-7" />}
          <span style={{ fontSize: '12px' }}>Theme</span>
        </button>
      </div>
    </nav>
  );
}
