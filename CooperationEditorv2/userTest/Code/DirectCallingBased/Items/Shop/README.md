Shop readme
===========

The shop items work together as follows:

# ATM

Dispenses [ShopCoin] if sufficient funds according to the [ShopMoneyManager].

# Buyable

Checks at start and when notified whether bought.  If not bought, hides itself.  If bought/once bought, appears in the level.

# ShopCoin

Carryable item that can be applied to [ShopItem] to part/fully pay.

# ShopItem

Accepts [ShopCoin] to part/fully pay.  Once bought, disappears, updates record to indicate item bought and notifies all [Buyable]s to see whether they're now bought.

# ShopMoneyManager

Central coordination of money within the Shop.
