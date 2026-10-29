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
- [x] **Step 3 – Item list:** Items with rarity + hidden true value.
  Test: debug button spawns random items.
- [ ] **Step 4 – Sellers walk in:** NPC customers walk to your counter with an item and ask a price.
  Test: a seller walks in, puts an item on the counter, asks a price, waits, then leaves (or you send them away).
- [ ] **Step 5 – Haggling (buying):** ⭐ Offer / Counter / Accept / Walk away. Customers have patience and mood.
  Test: hold E on a seller to haggle. Offer low, get countered, make a deal; cash goes down and the item is saved.
- [ ] **Step 6 – Inventory + shelves:** Bought items go to inventory; place them on display shelves.
  Test: buy an item, open 🎒 Inventory, press Display; it appears in a glass case. Rejoin and it's still there.
- [ ] **Step 7 – Buyers + selling:** Buyer NPCs browse shelves; haggle to sell high.
  Test: put an item on display; a buyer looks at it, offers a price at the counter; haggle up and sell. Buy low, sell high, cash goes up.
- [ ] **Step 8 – Appraisal:** True value is hidden; appraisal skill narrows the guess. Fakes and hidden treasures.
  Test: the haggle panel and inventory show an estimate range; use the admin menu to raise appraisal and see it narrow. Some items get spotted as fake / special.
- [ ] **Step 9 – Upgrades:** More shelves, faster customers, better appraisal, better haggling, bigger shop.
  Test: open ⬆ Upgrades, buy one (admin menu for cash); shelves allow more items, customers come sooner, estimates narrow, haggling gets easier. Bigger shop removes the ropes to the back area (behind the checkout island) for 18 more spots; buyers walk up the side aisles to browse it.
- [ ] **Step 10 – Rare items + events:** Legendary items, collection book, special visitors (shady seller, rich collector).
- [ ] **Step 11 – Rebirth + leaderboards:** Reset for a permanent bonus; top shops on the server.
- [ ] **Step 12 – Polish + publish:** Sounds, effects, tutorial, icon/thumbnails, publish. Optional gamepasses.
