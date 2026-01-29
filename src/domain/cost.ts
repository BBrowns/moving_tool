// Domain models - Cost
// Expense tracking and settlement calculation

export interface Expense {
    id: string;
    projectId: string;
    description: string;
    amount: number;         // in cents to avoid floating point issues
    paidById: string;       // User.id - who paid
    splitBetween: string[]; // User.id[] - who shares the cost
    date: Date;
    category?: string;
}

// Calculated settlement - who owes whom
export interface Settlement {
    fromUserId: string;
    toUserId: string;
    amount: number;         // in cents
}

// Calculate settlements from expenses
// Uses simplification algorithm to minimize number of transactions
export function calculateSettlements(expenses: Expense[], userIds: string[]): Settlement[] {
    // Calculate net balance for each user
    // Positive = owed money, Negative = owes money
    const balances: Record<string, number> = {};

    userIds.forEach(id => {
        balances[id] = 0;
    });

    expenses.forEach(expense => {
        const shareAmount = Math.floor(expense.amount / expense.splitBetween.length);

        // Payer gets credited the full amount
        balances[expense.paidById] += expense.amount;

        // Each person in split owes their share
        expense.splitBetween.forEach(userId => {
            balances[userId] -= shareAmount;
        });
    });

    // Create settlements - simple greedy algorithm
    const settlements: Settlement[] = [];
    const debtors = userIds.filter(id => balances[id] < 0);
    const creditors = userIds.filter(id => balances[id] > 0);

    debtors.forEach(debtor => {
        creditors.forEach(creditor => {
            if (balances[debtor] < 0 && balances[creditor] > 0) {
                const amount = Math.min(-balances[debtor], balances[creditor]);
                if (amount > 0) {
                    settlements.push({
                        fromUserId: debtor,
                        toUserId: creditor,
                        amount,
                    });
                    balances[debtor] += amount;
                    balances[creditor] -= amount;
                }
            }
        });
    });

    return settlements;
}

// Format cents to euros with symbol
export function formatCurrency(cents: number): string {
    return `€${(cents / 100).toFixed(2).replace('.', ',')}`;
}

// Parse euro string to cents
export function parseCurrency(euroString: string): number {
    const cleaned = euroString.replace(/[€\s]/g, '').replace(',', '.');
    return Math.round(parseFloat(cleaned) * 100);
}
