# Raising Gonthu

This is a work-in-progress deception game that you play in the console. It is
multiplayer. See the design folder for details about how that game functions.

The working name for the game is "Raising Gonthu" which comes from the goal for
demons - to raise Gonthu. The game is heavily inspired by Town of Salem, its
spiritual successor Throne of Lies, the series Wynonna Earp, and various
contemporary storylines.

# Design Considerations

The game is designed to be as friendly to developers as possible, so every
client gets the entire state of the game and there are easy tools (/inspect,
/runfile) to run custom code during the game or to inspect the state of the game.
The only unacceptable hack would be remote code execution, which is avoided
through the event system (assuming the json library doesn't have any security
issues)

# Running the Game

If you are on windows and have lua installed already, then just do "lua host_game.lua"
and follow the prompts.

Installing lua is a challenge on windows. One way to save some headache is
installing ZeroBrane Studio just for the lua binaries. It comes with most of the
popular lua libraries (this project requires LuaSocket and json).

For this project I am using Lua 5.1.5 on the standard interpreter. If you are
not familiar with installing lua I encourage you not to use LuaJIT since it
lost it's main maintainer in 2016.

# Platform

Currently the game runs on Windows only - this is just because I have a windows
machine and that's what I'm testing on. If you want to port the game to other
platforms, you need a new way to fetch available keys without blocking. The
current version (GetAvailableKeys.exe) is:

```C#
namespace IsKeyAvailableFramework
{
    class Program
    {
        static void Main(string[] args)
        {
            while (Console.KeyAvailable)
            {
                var key = Console.ReadKey(true); 
                var keyCode = (int)key.Key;

                Console.Write(keyCode.ToString());
                Console.Write(" ");
                Console.Write(key.KeyChar);
                Console.WriteLine();
            }
        }
    }
}
```

Additionally there are several locations (search for `os.execute`) where we use
windows command prompt to do stuff like determine console width. In most cases
the linux version of doing it is actually easier, so porting shouldn't take very
long if you can make the available keys thing work.
