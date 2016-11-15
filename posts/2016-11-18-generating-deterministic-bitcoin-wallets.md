If you are using Bitcoin regulary, you may have noticed that modern wallets let you
create multiple accounts with the same recovery seed and they derive a new address
each time you create a payment request. This is important for privacy reasons
(if you were reusing the same address, your balance and your transaction
history would be publicly visible on the blockchain).

Key derivation has much more exciting applications though. You can have a paper
wallet, stored securely, and you derive all your hot wallets from it. If a hot wallet
is compromised or lost, the rest of your wallets stay safe, and you can restore the funds
from the lost wallet using the paper wallet. Or, imagine a large organisation, where
there is a toplevel wallet managed by the CFO, and each department have there budgets
on their sub-wallets, having budget sub-wallets for different spending categories, and so on.

