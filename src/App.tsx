// Main App component - routing and initialization
import { useState, useEffect } from 'react';
import { useProjectStore, useTaskStore, usePackingStore, useShoppingStore, useCostStore } from './stores';

// Components
import { Layout } from './components/Layout/Layout';
import { Onboarding } from './features/onboarding/Onboarding';
import { Dashboard } from './features/dashboard/Dashboard';
import { TasksView } from './features/tasks/TasksView';
import { PackingView } from './features/packing/PackingView';
import { ShoppingView } from './features/shopping/ShoppingView';
import { CostsView } from './features/costs/CostsView';
import { ExportView } from './features/export/ExportView';

// Styles
import './index.css';
import './components/common/common.css';

type View = 'dashboard' | 'tasks' | 'packing' | 'shopping' | 'costs' | 'emails' | 'export';

function App() {
  const { project, users, isLoading: projectLoading, loadProject } = useProjectStore();
  const { loadTasks } = useTaskStore();
  const { loadPacking } = usePackingStore();
  const { loadItems } = useShoppingStore();
  const { loadExpenses } = useCostStore();

  const [currentView, setCurrentView] = useState<View>('dashboard');
  const [isInitialized, setIsInitialized] = useState(false);

  // Load project on mount
  useEffect(() => {
    loadProject().then(() => setIsInitialized(true));
  }, [loadProject]);

  // Load all data when project is available
  useEffect(() => {
    if (project) {
      loadTasks(project.id);
      loadPacking(project.id);
      loadItems(project.id);
      loadExpenses(project.id, users.map(u => u.id));
    }
  }, [project, users, loadTasks, loadPacking, loadItems, loadExpenses]);

  // Handle navigation from sidebar
  const handleNavigate = (path: string) => {
    setCurrentView(path as View);
  };

  // Show loading state
  if (!isInitialized || projectLoading) {
    return (
      <div className="loading-screen">
        <div className="spinner"></div>
        <p>Laden...</p>
      </div>
    );
  }

  // Show onboarding if no project
  if (!project) {
    return <Onboarding onComplete={() => loadProject()} />;
  }

  // Render current view
  const renderView = () => {
    switch (currentView) {
      case 'dashboard':
        return <Dashboard />;
      case 'tasks':
        return <TasksView />;
      case 'packing':
        return <PackingView />;
      case 'shopping':
        return <ShoppingView />;
      case 'costs':
        return <CostsView />;
      case 'emails':
      case 'export':
        return <ExportView />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <Layout activePath={currentView} onNavigate={handleNavigate}>
      {renderView()}
    </Layout>
  );
}

export default App;
