--[[
    ForeverCCG - Tragic: The Saddening Engine  |  © 2026 the_naked_gypsy
    Copyright (c) 2026 the_naked_gypsy. All Rights Reserved.

    This file is part of ForeverCCG. See LICENSE.txt for terms.
    World of Warcraft names, creatures, icons and models are the property of
    Blizzard Entertainment, Inc. and are not claimed by this notice.
]]
TTS = TTS or {}

-- =========================================================================
-- SOLO MAP POSITIONS
-- Where each solo encounter's button sits on its continent map: EK (Eastern Kingdoms)
-- or KAL (Kalimdor), x 0-1 from the left edge, y 0-1 from the top.
-- Zones: the centre of the zone. Dungeons: the entrance (its teleport triggers).
-- Generated from the Classic Era client tables UiMapAssignment and AreaTrigger, and
-- classicdb areatrigger_teleport.
-- =========================================================================
TTS.SoloMapPositions = {
    ALT = { "EK", 0.4721, 0.2940 },
    ARA = { "EK", 0.5303, 0.3750 },
    ASH = { "KAL", 0.4959, 0.4096 },
    AZS = { "KAL", 0.6217, 0.3729 },
    BAD = { "EK", 0.5489, 0.6045 },
    BFD = { "KAL", 0.4432, 0.3484 },
    BLA = { "EK", 0.5374, 0.8161 },
    BRD = { "EK", 0.4812, 0.6240 },
    BRN = { "KAL", 0.5302, 0.5937 },
    BRS = { "EK", 0.4897, 0.6386 },
    BUR = { "EK", 0.5037, 0.6594 },
    DAR = { "KAL", 0.4728, 0.2711 },
    DES = { "KAL", 0.4098, 0.5644 },
    DMA = { "KAL", 0.4393, 0.6769 },
    DMS = { "EK", 0.4067, 0.7958 },
    DSK = { "EK", 0.4692, 0.7706 },
    DUN = { "EK", 0.4733, 0.5534 },
    DUR = { "KAL", 0.5889, 0.5199 },
    DUS = { "KAL", 0.5616, 0.6760 },
    ELW = { "EK", 0.4602, 0.7058 },
    EPL = { "EK", 0.5716, 0.2112 },
    FEL = { "KAL", 0.4973, 0.3091 },
    FER = { "KAL", 0.4103, 0.7126 },
    GNO = { "EK", 0.4300, 0.5317 },
    -- WoW Forever dungeons: entrances placed by hand from the Wowhead guides (approximate)
    HOT = { "EK", 0.4790, 0.5230 },   -- under the High Seat of Ironforge
    ROL = { "EK", 0.4490, 0.2400 },   -- the ruins above the Undercity
    EXC = { "EK", 0.5065, 0.4690 },   -- western Wetlands
    DAL = { "EK", 0.4455, 0.3065 },   -- Dalaran, western Alterac Mountains
    RIV = { "EK", 0.5600, 0.6800 },   -- Riverglades, between Redridge, Burning Steppes, Badlands and Swamp of Sorrows
    HIL = { "EK", 0.4697, 0.3466 },
    HIN = { "EK", 0.5540, 0.3104 },
    LOC = { "EK", 0.5504, 0.5486 },
    MAR = { "KAL", 0.3893, 0.5761 },
    MUL = { "KAL", 0.4779, 0.6027 },
    RED = { "EK", 0.5300, 0.7144 },
    RFC = { "KAL", 0.5841, 0.4476 },
    RFD = { "KAL", 0.5327, 0.7120 },
    RFK = { "KAL", 0.5088, 0.7034 },
    SCH = { "EK", 0.5270, 0.2635 },
    SEA = { "EK", 0.4954, 0.6098 },
    SFK = { "EK", 0.4098, 0.3280 },
    SIL = { "EK", 0.4162, 0.3068 },
    SLI = { "KAL", 0.4421, 0.8119 },
    SMO = { "EK", 0.4779, 0.1947 },
    STK = { "EK", 0.4304, 0.6916 },
    STO = { "KAL", 0.4419, 0.4692 },
    STR = { "EK", 0.5570, 0.1758 },
    STV = { "EK", 0.4821, 0.8848 },
    SUN = { "EK", 0.5681, 0.7513 },
    SWA = { "EK", 0.5503, 0.7607 },
    TAN = { "KAL", 0.5635, 0.8550 },
    TEL = { "KAL", 0.4293, 0.1086 },
    THO = { "KAL", 0.5353, 0.7432 },
    TIR = { "EK", 0.4326, 0.2188 },
    ULD = { "EK", 0.5500, 0.5879 },
    UNG = { "KAL", 0.4995, 0.8152 },
    WCV = { "KAL", 0.5239, 0.5525 },
    WES = { "EK", 0.4186, 0.7685 },
    WET = { "EK", 0.5244, 0.4684 },
    WIN = { "KAL", 0.5688, 0.2704 },
    WPL = { "EK", 0.5038, 0.2358 },
    ZFK = { "KAL", 0.5423, 0.7978 },
}
