import React, { useState } from 'react';
import { Page } from '../../App';

interface LoginPageProps {
  setCurrentPage: (page: Page) => void;
  onLogin: () => void;
}

export function LoginPage({ setCurrentPage, onLogin }: LoginPageProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onLogin();
  };

  return (
    <div style={{ 
      minHeight: 'calc(100vh - 80px)',
      padding: '20px',
      maxWidth: '600px',
      margin: '0 auto',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center'
    }}>
      <h1 style={{ 
        color: 'var(--color-text)',
        fontSize: '32px',
        textAlign: 'center',
        margin: '0 0 32px 0'
      }}>
        Login
      </h1>

      <form onSubmit={handleSubmit}>
        <div style={{ marginBottom: '20px' }}>
          <label 
            htmlFor="email"
            style={{ 
              color: 'var(--color-text)', 
              fontSize: '18px',
              display: 'block',
              marginBottom: '8px'
            }}
          >
            Email
          </label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            placeholder="your@email.com"
            style={{ 
              width: '100%',
              height: '56px',
              fontSize: '18px',
              padding: '0 16px',
              borderRadius: '8px',
              border: '1px solid var(--color-border)',
              backgroundColor: 'var(--color-bg)',
              color: 'var(--color-text)',
              outline: 'none'
            }}
          />
        </div>

        <div style={{ marginBottom: '32px' }}>
          <label 
            htmlFor="password"
            style={{ 
              color: 'var(--color-text)', 
              fontSize: '18px',
              display: 'block',
              marginBottom: '8px'
            }}
          >
            Password
          </label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            placeholder="••••••••"
            style={{ 
              width: '100%',
              height: '56px',
              fontSize: '18px',
              padding: '0 16px',
              borderRadius: '8px',
              border: '1px solid var(--color-border)',
              backgroundColor: 'var(--color-bg)',
              color: 'var(--color-text)',
              outline: 'none'
            }}
          />
        </div>

        <button
          type="submit"
          style={{
            width: '100%',
            height: '60px',
            backgroundColor: 'var(--color-button-blue)',
            color: 'white',
            border: 'none',
            borderRadius: '12px',
            fontSize: '20px',
            fontWeight: 600,
            cursor: 'pointer',
            boxShadow: '0 2px 8px rgba(0,0,0,0.15)'
          }}
        >
          Log In
        </button>
      </form>

      <div style={{ textAlign: 'center', marginTop: '24px' }}>
        <button
          onClick={() => setCurrentPage('signup')}
          style={{
            background: 'none',
            border: 'none',
            color: 'var(--color-primary)',
            fontSize: '18px',
            cursor: 'pointer',
            textDecoration: 'underline'
          }}
        >
          Don't have an account? Sign up
        </button>
      </div>
    </div>
  );
}
