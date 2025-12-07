import React from 'react';

interface PageContainerProps {
  children: React.ReactNode;
  className?: string;
}

export function PageContainer({ children, className = '' }: PageContainerProps) {
  return (
    <div 
      className={`page-container ${className}`}
      style={{ backgroundColor: 'var(--color-bg)' }}
    >
      {children}

      <style jsx>{`
        .page-container {
          margin-top: 20px;
          border-radius: 25px;
          padding: 30px 50px;
          margin-bottom: 50px;
          box-shadow: 0 2px 5px 0 rgba(0,0,0,0.08);
        }

        @media (max-width: 768px) {
          .page-container {
            padding: 20px 20px;
            border-radius: 15px;
          }
        }
      `}</style>
    </div>
  );
}
