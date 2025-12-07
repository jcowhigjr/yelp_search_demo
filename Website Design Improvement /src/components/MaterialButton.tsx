import React from 'react';

interface MaterialButtonProps {
  children: React.ReactNode;
  size?: 'large' | 'small';
  variant?: 'primary' | 'secondary';
  onClick?: () => void;
  type?: 'button' | 'submit';
  className?: string;
  disabled?: boolean;
}

export function MaterialButton({ 
  children, 
  size = 'large', 
  variant = 'primary',
  onClick, 
  type = 'button',
  className = '',
  disabled = false
}: MaterialButtonProps) {
  const baseStyles = {
    backgroundColor: variant === 'primary' ? 'var(--color-button-blue)' : 'var(--color-primary)',
    color: 'white',
  };

  const sizeClasses = size === 'large' 
    ? 'px-8 py-4 text-lg' 
    : 'px-6 py-2 text-sm';

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`
        btn-material
        ${sizeClasses}
        ${className}
      `}
      style={baseStyles}
    >
      {children}

      <style jsx>{`
        .btn-material {
          border: none;
          border-radius: 4px;
          cursor: pointer;
          font-weight: 500;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
          display: inline-block;
          position: relative;
          overflow: hidden;
        }

        .btn-material:hover:not(:disabled) {
          box-shadow: 0 5px 11px 0 rgba(0,0,0,0.18), 0 4px 15px 0 rgba(0,0,0,0.15);
          transform: translateY(-1px);
        }

        .btn-material:active:not(:disabled) {
          box-shadow: 0 2px 5px 0 rgba(0,0,0,0.16), 0 2px 10px 0 rgba(0,0,0,0.12);
          transform: translateY(0);
        }

        .btn-material:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }
      `}</style>
    </button>
  );
}
