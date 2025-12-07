import React, { useState } from 'react';
import { SearchPage } from './components/pages/SearchPage';
import { ResultsPage } from './components/pages/ResultsPage';
import { DetailPage } from './components/pages/DetailPage';
import { LoginPage } from './components/pages/LoginPage';
import { SignupPage } from './components/pages/SignupPage';
import { FavoritesPage } from './components/pages/FavoritesPage';
import { Navigation } from './components/Navigation';
import { Footer } from './components/Footer';
import { LanguageSelector, Language } from './components/LanguageSelector';
import { Sun, Moon } from 'lucide-react';

export type Page = 'search' | 'results' | 'detail' | 'login' | 'signup' | 'favorites';

export default function App() {
  const [currentPage, setCurrentPage] = useState<Page>('search');
  const [selectedShopId, setSelectedShopId] = useState<number | null>(null);
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [language, setLanguage] = useState<Language>('en');

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light';
    setTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  };

  const handleViewDetail = (id: number) => {
    setSelectedShopId(id);
    setCurrentPage('detail');
  };

  const handleLogin = () => {
    setIsLoggedIn(true);
    setCurrentPage('search');
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCurrentPage('search');
  };

  return (
    <div className="min-h-screen flex flex-col" style={{ paddingBottom: '80px' }}>
      <LanguageSelector currentLanguage={language} onLanguageChange={setLanguage} />
      
      <main className="flex-1">
        {currentPage === 'search' && (
          <SearchPage setCurrentPage={setCurrentPage} />
        )}
        {currentPage === 'results' && (
          <ResultsPage 
            setCurrentPage={setCurrentPage}
            onViewDetail={handleViewDetail}
          />
        )}
        {currentPage === 'detail' && selectedShopId && (
          <DetailPage 
            shopId={selectedShopId}
            setCurrentPage={setCurrentPage}
          />
        )}
        {currentPage === 'login' && (
          <LoginPage 
            setCurrentPage={setCurrentPage}
            onLogin={handleLogin}
          />
        )}
        {currentPage === 'signup' && (
          <SignupPage setCurrentPage={setCurrentPage} />
        )}
        {currentPage === 'favorites' && (
          <FavoritesPage 
            setCurrentPage={setCurrentPage}
            onViewDetail={handleViewDetail}
          />
        )}
      </main>

      <Navigation 
        currentPage={currentPage} 
        setCurrentPage={setCurrentPage}
        isLoggedIn={isLoggedIn}
        onLogout={handleLogout}
        theme={theme}
        toggleTheme={toggleTheme}
      />
    </div>
  );
}
