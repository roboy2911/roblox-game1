# Pawn Shop Simulator – Build Plan

**The game:** Customers bring in random items. Haggle to buy them cheap, sell them to other customers for a profit, and sometimes find out the junk is a rare treasure.

- Each player gets their **own shop plot**.
- Code is synced into Roblox Studio with **Rojo** from this repo.
- 3D models (items, shop props) are made in **Blender** and imported into Studio.

## How each step works
1. Claude pushes code to this repo.
2. You click **Pull** in GitHub Desktop.
3. Rojo updates Studio automatically.
4. Press **Play**, test, give feedback. Adjust, then move to the next step.

## Steps

- [x] **Step 0 – Setup:** Install GitHub Desktop + Rojo, connect Studio to the repo, push starter project.
  Test: Output shows "Pawn Shop loaded!"
- [x] **Step 1 – Cash + saving:** Cash on the leaderboard, saved with DataStores.
  Test: rejoin and your cash is still there.
- [x] **Step 2 – Your shop:** Each player is assigned their own shop plot (counter, shelves, door).
  Test: join and get a shop.
- [ ] **Step 3 – Item list:** Items with rarity + hidden true value.
  Test: debug button spawns random items.
- [ ] **Step 4 – Sellers walk in:** NPC customers walk to your counter with an item and ask a price.
- [ ] **Step 5 – Haggling (buying):** ⭐ Offer / Counter / Accept / Walk away. Customers have patience and mood.
- [ ] **Step 6 – Inventory + shelves:** Bought items go to inventory; place them on display shelves.
- [ ] **Step 7 – Buyers + selling:** Buyer NPCs browse shelves; haggle to sell high.
  Test: buy low, sell high, cash goes up.
- [ ] **Step 8 – Appraisal:** True value is hidden; appraisal skill narrows the guess. Fakes and hidden treasures.
- [ ] **Step 9 – Upgrades:** More shelves, faster customers, better appraisal, better haggling, bigger shop.
- [x] **Step 10 – Rare items + events:** Legendary items, collection book, special visitors (shady seller, rich collector).
- [x] **Step 11 – Rebirth + leaderboards:** Reset for a permanent bonus; top shops on the server.
- [x] **Step 12 – Polish + publish:** Sounds, effects, tutorial, icon/thumbnails, publish. Optional gamepasses.
