import React, { useState, useRef, useEffect } from 'react';
import { Globe, ChevronDown } from 'lucide-react';

export type Language = 'en' | 'es' | 'fr';

interface LanguageSelectorProps {
  currentLanguage: Language;
  onLanguageChange: (language: Language) => void;
}

const languages = {
  en: 'English',
  es: 'Español',
  fr: 'Français',
};

export function LanguageSelector({ currentLanguage, onLanguageChange }: LanguageSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const handleLanguageSelect = (language: Language) => {
    onLanguageChange(language);
    setIsOpen(false);
  };

  return (
    <div 
      ref={dropdownRef}
      className="fixed top-4 right-4 z-50"
      style={{ zIndex: 1000 }}
    >
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-[var(--color-border)] transition-all"
        style={{
          backgroundColor: 'var(--color-bg)',
          color: 'var(--color-text)',
          backdropFilter: 'blur(10px)',
          boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
        }}
      >
        <Globe size={18} />
        <span className="uppercase">{currentLanguage}</span>
        <ChevronDown 
          size={16} 
          style={{ 
            transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)',
            transition: 'transform 0.2s'
          }} 
        />
      </button>

      {isOpen && (
        <div
          className="absolute top-full right-0 mt-2 rounded-lg border border-[var(--color-border)] overflow-hidden"
          style={{
            backgroundColor: 'var(--color-bg)',
            minWidth: '140px',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          }}
        >
          {(Object.keys(languages) as Language[]).map((lang) => (
            <button
              key={lang}
              onClick={() => handleLanguageSelect(lang)}
              className="w-full text-left px-4 py-3 transition-colors"
              style={{
                color: 'var(--color-text)',
                backgroundColor: currentLanguage === lang ? 'rgba(75, 156, 211, 0.1)' : 'transparent',
                borderLeft: currentLanguage === lang ? '3px solid var(--color-primary)' : '3px solid transparent',
              }}
              onMouseEnter={(e) => {
                if (currentLanguage !== lang) {
                  e.currentTarget.style.backgroundColor = 'rgba(0, 0, 0, 0.05)';
                }
              }}
              onMouseLeave={(e) => {
                if (currentLanguage !== lang) {
                  e.currentTarget.style.backgroundColor = 'transparent';
                }
              }}
            >
              {languages[lang]}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
