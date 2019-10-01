Scriptname DTSleep_DressData extends Quest Conditional

; Dress Data for Sleep Intimate 
; DracoTorre
; 
; checking lists using IsEquipped or GetItemCount consumes time
; storing here saves time where Player updates on Equip/Unequip
; These items are special armor using extra slots and having no keywords
;
; *LastEquiped* items hold replaced unequipped items which actor 
; may no longer have. Store to save time for matching when actor
; equips again later - most useful when auto-undress then redress

; when using scripts to equip / unequip best to disable searching
;
;
bool property SearchListsDisabled = false auto conditional hidden
{ toggle to tell equip monitor to skip searching lists }

int property PlayerGender = -1 auto conditional hidden

; player main outfit data
Armor property PlayerEquippedHat auto conditional hidden
Armor property PlayerEquippedBodyOutfit auto conditional hidden
{ not currently used - no keywords }
Armor property PlayerEquippedMask auto conditional hidden
Armor property PlayerLastEquippedHat auto conditional hidden
Armor property PlayerLastEquippedBodyOutfit auto conditional hidden
{ not currently only used if on armor-all list - no keywords }
Armor property PlayerLastEquippedMask auto conditional hidden

; player extra parts

bool property PlayerBackPackNoGOModel = false auto conditional hidden
{ if equipped backpack lacks a ground object }
bool property PlayerHasExtraPartsEquipped = false auto conditional hidden
{ if have armor items from ExtraParts list no other slot }
bool property PlayerHasExtraClothingEquipped = false auto  conditional hidden
{ if have armor items from extra clothing list }
bool property PlayerHasArmorAllEquipped = false auto conditional hidden
{ if main body also includes outer armor slots }
bool property PlayerHasSexyOutfitEquipped = false auto conditional hidden
Armor property PlayerEquippedBackpackItem auto conditional hidden
{ backpack / packs - set here only - never slots }
Armor property PlayerEquippedCarryPouchItem auto conditional hidden
{ adds carry but not placed like backpack (Nuka Bear) }
Armor property PlayerEquippedChokerItem auto conditional hidden
{ only beard slot and for sex appeal }
Armor property PlayerEquippedNecklaceItem auto conditional hidden
{ only necklace slot and for sex appeal - not all necklaces }
Armor property PlayerEquippedJacketItem auto conditional hidden
{ jackets priority over slots }
Armor property PlayerEquippedSleepwearItem auto conditional hidden
{ a sleep item of regular body slot only - see special slots }
Armor property PlayerEquippedSlot41Item auto conditional hidden
Armor property PlayerEquippedSlot55Item auto conditional hidden
Armor property PlayerEquippedSlot58Item = None auto conditional hidden
bool property PlayerEquippedSlot58IsSleepwear = false auto conditional hidden
{ if slot 58 is a sleepwear item }
Armor property PlayerEquippedSlotFXItem auto conditional hidden
{ slot 61 FX item  }
Armor property PlayerEquippedULegItem auto conditional hidden
bool property PlayerEquippedSlotFXIsSleepwear auto conditional hidden
{ if slot 61/FX is a sleepwear item }
Armor property PlayerEquippedStrapOnItem auto conditional hidden
Armor property PlayerEquippedIntimateAttireItem = None auto conditional hidden
Armor property PlayerEquippedGlassesItem = None auto conditional hidden
Armor property PlayerEquippedArmorTorsoItem = None auto conditional hidden
Armor property PlayerEquippedArmorArmLeftItem = None auto conditional hidden
Armor property PlayerEquippedArmorArmRightItem = None auto conditional hidden
Armor property PlayerEquippedArmorLegLeftItem = None auto conditional hidden
Armor property PlayerEquippedArmorLegRightItem = None auto conditional hidden

; --- last 

Armor property PlayerLastEquippedBackpackItem auto conditional hidden
{ last backpack / pack - never in slot }
Armor property PlayerLastEquippedJacketItem auto conditional hidden
{ last jacket priority over slots }
Armor property PlayerLastEquippedSleepwearItem auto conditional hidden
{ a sleep item - may be duplicated in a custom slot here }
Armor property PlayerLastEquippedSlot41Item auto conditional hidden
Armor property PlayerLastEquippedSlot55Item auto conditional hidden
Armor property PlayerLastEquippedSlot58Item auto conditional hidden
bool property PlayerLastEquippedSlot58IsSleepwear = false auto conditional hidden
{ if last slot 58 is a sleepwear item }
Armor property PlayerLastEquippedSlotFXItem auto conditional hidden
{ last slot 61 FX item  }
Armor property PlayerLastEquippedULegItem auto conditional hidden
bool property PlayerLastEquippedSlotFXIsSleepwear = false auto conditional hidden
{ if last slot 61/FX is a sleepwear item }
Armor property PlayerLastEquippedStrapOnItem auto conditional hidden
{ last strap-on takes priority over slots }
Armor property PlayerLastEquippedIntimateAttireItem = None auto conditional hidden
Armor property PlayerLastEquippedGlassesItem = None auto conditional hidden

; --------------------------- companion -------------

Actor property CompanionActor auto conditional hidden
bool property CompanionDressValid = false auto conditional hidden
bool property CompanionDressArmorAllValid = false auto conditional hidden
bool property CompanionDressArmorExtendedValid = false auto conditional hidden
int property CompanionGender = -1 auto conditional hidden
bool property CompanionRequiresNudeSuit = true auto conditional hidden
int property CompanionCustomRestrictSlot = -1 auto conditional hidden

Armor property CompanionNudeSuit = None auto conditional hidden
Armor property CompanionHat auto conditional hidden
Armor property CompanionChokerItem auto conditional hidden
Armor property CompanionNecklaceItem auto conditional hidden
Armor property CompanionOutfitBody auto conditional hidden
Armor property CompanionEquippedMask auto conditional hidden
Armor property CompanionEquippedGlassesItem auto conditional hidden

bool property CompanionBackPackNoGOModel = false auto conditional hidden
bool property CompanionHasExtraPartsEquipped = false auto conditional hidden
{ if have armor items from ExtraParts list no other slot }
bool property CompanionHasExtraClothingEquipped = false auto  conditional hidden
{ if have armor items from extra clothing list }
Armor property CompanionEquippedBackpackItem auto conditional hidden
Armor property CompanionEquippedCarryPouchItem auto conditional hidden
{ adds carry but not placed like backpack (Nuka Bear) }
Armor property CompanionEquippedJacketItem auto conditional hidden
Armor property CompanionEquippedSleepwearItem auto conditional hidden
{ a sleep item - may be duplicated in a custom slot here }
Armor property CompanionEquippedSlot41Item auto conditional hidden
Armor property CompanionEquippedSlot55Item auto conditional hidden
Armor property CompanionEquippedSlot58Item auto conditional hidden
Armor property CompanionEquippedSlotFXItem auto conditional hidden
{ slot 61 FX item  }
Armor property CompanionEquippedULegItem auto conditional hidden
Armor property CompanionEquippedStrapOnItem auto conditional hidden
Armor property CompanionEquippedIntimateAttireItem = None auto conditional hidden

bool property CompanionEquippedSlot58IsSleepwear = false auto conditional hidden
{ if slot 58 is a sleepwear item }
bool property CompanionEquippedSlotFXIsSleepwear = false auto conditional hidden
{ if slot 61/FX is sleepwear }
Armor property CompanionEquippedArmorTorsoItem = None auto conditional hidden
Armor property CompanionEquippedArmorArmLeftItem = None auto conditional hidden
Armor property CompanionEquippedArmorArmRightItem = None auto conditional hidden
Armor property CompanionEquippedArmorLegLeftItem = None auto conditional hidden
Armor property CompanionEquippedArmorLegRightItem = None auto conditional hidden
; -- last 

bool property CompanionLastSlotFXIsSleepwear = false auto conditional hidden
{ if last slot 61/FX is a sleepwear item }
Armor property CompanionLastEquippedBackpackItem auto conditional hidden
Armor property CompanionLastEquippedJacketItem auto conditional hidden
Armor property CompanionLastEquippedSleepwearItem auto conditional hidden
{ a sleep item - may be duplicated in a custom slot here }
bool property CompanionLastSlot58IsSleepwear = false auto conditional hidden
Armor property CompanionLastEquippedSlot41Item auto conditional hidden
Armor property CompanionLastEquippedSlot55Item auto conditional hidden
Armor property CompanionLastEquippedSlot58Item auto conditional hidden
Armor property CompanionLastEquippedSlotFXItem auto conditional hidden
{ slot 61 FX item  }
Armor property CompanionLastEquippedULegItem auto conditional hidden
Armor property CompanionLastEquippedStrapOnItem auto conditional hidden
Armor property CompanionLastEquippedIntimateAttireItem = None auto conditional hidden
Armor property CompanionLastEquippedGlassesItem auto conditional hidden

bool property CompanionHasArmorAllEquipped = false auto conditional hidden
{ if main body also includes outer armor slots }

