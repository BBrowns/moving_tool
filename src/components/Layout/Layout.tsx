// Layout component with sidebar navigation
import { type ReactNode } from 'react';
import { Sidebar } from './Sidebar';
import './Layout.css';

interface LayoutProps {
    children: ReactNode;
    activePath?: string;
    onNavigate?: (path: string) => void;
}

export function Layout({ children, activePath, onNavigate }: LayoutProps) {
    return (
        <div className="layout">
            <Sidebar activePath={activePath} onNavigate={onNavigate} />
            <main className="main-content">
                {children}
            </main>
        </div>
    );
}
