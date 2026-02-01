import { useTheme } from '../../context/ThemeContext';
import './ThemeToggle.css';

export function ThemeToggle() {
    const { theme, setTheme } = useTheme();

    return (
        <button
            className="theme-toggle"
            onClick={() => {
                if (theme === 'light') setTheme('dark');
                else if (theme === 'dark') setTheme('system');
                else setTheme('light');
            }}
            title={`Current theme: ${theme}`}
            aria-label="Toggle theme"
        >
            <span className={`toggle-icon ${theme === 'light' ? 'active' : ''}`}>☀️</span>
            <span className={`toggle-icon ${theme === 'dark' ? 'active' : ''}`}>🌙</span>
            <span className={`toggle-icon ${theme === 'system' ? 'active' : ''}`}>💻</span>
        </button>
    );
}
