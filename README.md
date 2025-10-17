This plugin integrates Trackmania with the multiworld randomizer project Archipelago.

# Installation Guide
1. Install this plugin!
2. Install the [Archipelago Client](https://github.com/ArchipelagoMW/Archipelago/releases)
3. Download the latest trackmania.apworld file from [here](https://github.com/SerialBoxes/ArchipelagoTrackmania/releases)
4. Double-Click the trackmania.apworld file to install it.

# Setup Guide
1. In the Archipelago Client, click Open for Generate Template Options
2. Navigate to <Archipelago Client Installation Folder>/Players/Templates if it did not do so automatically
3. Copy the Trackmania.yaml file somewhere safe and cozy, and then edit the options inside it how you like.
4. Either give this .yaml file to the person hosting your multiworld, or add it to /Players folder just like any other if you are hosting yourself. If you need a general Archipelago Tutorial, [Click Here](https://archipelago.gg/tutorial/Archipelago/setup_en). (Note: All multiworlds with Trackmania must be generated locally until it is merged into core)
5. When the Archipelago Server is running, launch the Trackmania Client from the Archipelago Client (hang in there!)
6. Connect the Trackmania Client using the /connect command or the Connect button at the top, and follow the instructions in the console.
7. Open the Archipelago Plugin in Trackmania, and hit connect. Have fun! <3

# Information
## What is Archipelago?
Archipelago is an open source community project that enables multiplayer randomizers. Each player picks their own game they would like to play, and Archipelago randomizes all of the items in it, just like a normal randomizer. The catch is that items are randomized between games. You may find a Master Sword when you get the Author Time, and your friend may get your Author Medal instead of finding the princess is in another castle. This is a great way to play your favorite games with your friends, especially if they are singleplayer only or you have different tastes in games.

## How on Earth does this work with Trackmania?
That's a good question! This mode is similar to Flink's [Random Map Challenge](https://flinkblog.de/RMC/), but loosely in the structure of the official campaigns. At the start of the game, you will have access to a random number of maps from [Trackmania Exchange](https://trackmania.exchange/). Your goal is to beat your target time on each of these tracks. You can choose any medal, or any time between any two medals, as your target time. The quickest medal that is still slower than or equal to your target time is considered your progression medal. When you have the progression medals from 80% tracks in a series (by default), you can move on to the next series, which has an additional set of tracks. Once you have completed 5 series (by default), you have won the randomizer! Of course, the number of maps in a series, the number of series, your target time, and much more are all configurable in your .yaml configuration file.

The catch here is that all of your medals have been randomized! When you drive a run that beats a medal time, say the gold medal time for example, you will (probably) not get a gold medal. You will get a different medal, or an item from another player's game. Other players in your server will have to find your medals in their worlds in order for you to progress to the next series. Every medal time below your target time, as well as the target time itself, all count as "locations" that items from any world in the server can be in (by default).

## Are there any additional items?
Some of the maps on Trackmania Exchange are incredibly difficult. If another player's important progression item has taken the place of the author medal on a track you cannot beat, there is still hope! There are a few map skip items that have been added to the item pool. When you use one, it will complete the currently loaded track and collect all the items that were on the map. Use them wisely, there aren't that many! There is also a PB discount item, which instead will lower your PB time used by the plugin by 1.5% (by default). This is useful for maps where you are close but not quite able to reach your target time! These items are a bit more common (by default).

## Why did I just get an item called Yep Tree?
Archipelago requires all worlds to generate the same number of items and locations. To satisfy this without giving way too many Map Skips to the players, this randomizer generates some filler items. These have been given fun names that reference the Trackmania community. If you get an item with a crazy name, that is what is happening! Medals below your progression medal currently have no real value in the randomizer. You can disable them in the options if you prefer.

## Help, I got a broken map!
You can use the /reroll command in the Trackmania Client to reroll the currently loaded map, or /reroll <series number> <map number> to reroll any map from the main menu.

## Do I need Club Access?
Yes.

## What Titlepacks are supported in TM2?
TM Canyon, TM Stadium, TM Valley, TM Lagoon, and TM All are all supported. Other titlepacks have not been specifically excluded, but are also not supported. They may or may not work, try at your own risk!
