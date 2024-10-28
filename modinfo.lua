
meta =
{
    -- ID of your mod; Make sure this is unique!
    -- Will be used for identifying the mod in dependency lists
    -- Will be changed to workshop ID (ensuring uniqueness) when you upload the mod to the workshop
    id = "3315794988",

    -- Name of your mod; You may want this to be unique, but it's not absolutely necessary.
    -- This is an additional helper attribute for you to easily identify your mod in the Mods() list
    name = "CosmicOverhaul",

    -- Title of your mod that will be displayed to players
    title = "Cosmic Overhaul",

    -- Type of your mod, either "mod" or "factionpack"
    type = "mod",

    -- Description of your mod that will be displayed to players
    description = "Overhauls and adds many Quality of Life features for Avorion. For full description please read the mod page.",

    -- Insert all authors into this list
    authors = {"Stormbox"},

    -- Version of your mod, should be in format 1.0.0 (major.minor.patch) or 1.0 (major.minor)
    -- This will be used to check for unmet dependencies or incompatibilities, and to check compatibility between clients and dedicated servers with mods.
    -- If a client with an unmatching major or minor mod version wants to log into a server, login is prohibited.
    -- Unmatching patch version still allows logging into a server. This works in both ways (server or client higher or lower version).
    version = "2.1.0",

    -- If your mod requires dependencies, enter them here. The game will check that all dependencies given here are met.
    -- Possible attributes:
    -- id: The ID of the other mod as stated in its modinfo.lua
    -- min, max, exact: version strings that will determine minimum, maximum or exact version required (exact is only syntactic sugar for min == max)
    -- optional: set to true if this mod is only an optional dependency (will only influence load order, not requirement checks)
    -- incompatible: set to true if your mod is incompatible with the other one
    -- Example:
    -- dependencies = {
    --      {id = "Avorion", min = "0.17", max = "0.21"}, -- we can only work with Avorion between versions 0.17 and 0.21
    --      {id = "SomeModLoader", min = "1.0", max = "2.0"}, -- we require SomeModLoader, and we need its version to be between 1.0 and 2.0
    --      {id = "AnotherMod", max = "2.0"}, -- we require AnotherMod, and we need its version to be 2.0 or lower
    --      {id = "IncompatibleMod", incompatible = true}, -- we're incompatible with IncompatibleMod, regardless of its version
    --      {id = "IncompatibleModB", exact = "2.0", incompatible = true}, -- we're incompatible with IncompatibleModB, but only exactly version 2.0
    --      {id = "OptionalMod", min = "0.2", optional = true}, -- we support OptionalMod optionally, starting at version 0.2
    -- },
    dependencies = {
        {id = "2416624076", exact = "*.*", incompatible = true},
        {id = "2662062462", exact = "*.*", incompatible = true},
        {id = "3042506675", exact = "*.*", incompatible = true},
        {id = "2594711721", exact = "*.*", incompatible = true},
        {id = "2606086199", exact = "*.*", incompatible = true},
        {id = "2595742135", exact = "*.*", incompatible = true},
        {id = "2778851215", exact = "*.*", incompatible = true},
        {id = "2323452485", exact = "*.*", incompatible = true},
        {id = "2644933411", exact = "*.*", incompatible = true},
        {id = "1876566104", exact = "*.*", incompatible = true},
        {id = "2579166263", exact = "*.*", incompatible = true},
        {id = "2853246039", exact = "*.*", incompatible = true},
        {id = "1788913474", exact = "*.*", incompatible = true},
        {id = "2853436262", exact = "*.*", incompatible = true},
        {id = "2674287322", exact = "*.*", incompatible = true},
        {id = "2853141522", exact = "*.*", incompatible = true},
        {id = "2796950857", exact = "*.*", incompatible = true},
        {id = "2427929909", exact = "*.*", incompatible = true},
        {id = "1722263986", exact = "*.*", incompatible = true},
        {id = "2842885870", exact = "*.*", incompatible = true},
        {id = "2049880869", exact = "*.*", incompatible = true},
        {id = "2589975318", exact = "*.*", incompatible = true},
        {id = "3232924424", exact = "*.*", incompatible = true},
        {id = "3232919558", exact = "*.*", incompatible = true},
        {id = "Avorion", min = "1.0", max = "5.0"}
    },

    -- Set to true if the mod only has to run on the server. Clients will get notified that the mod is running on the server, but they won't download it to themselves
    serverSideOnly = false,

    -- Set to true if the mod only has to run on the client, such as UI mods
    clientSideOnly = false,

    -- Set to true if the mod changes the savegame in a potentially breaking way, as in it adds scripts or mechanics that get saved into database and no longer work once the mod gets disabled
    -- logically, if a mod is client-side only, it can't alter savegames, but Avorion doesn't check for that at the moment
    saveGameAltering = true,

    -- Contact info for other users to reach you in case they have questions
    contact = "Contact me on Discord: stormbox - I am also on the official Avorion Discord!",
}
