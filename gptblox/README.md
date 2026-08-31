# GPTBlox - Prompt Panic

GPTBlox is a Roblox experiment built around a simple idea: the world behaves as if an unreliable AI is generating the obstacle course while you play it.

The first game mode is **Prompt Panic**, a short solo/co-op procedural obstacle run. The MVP does not call an external AI service. Instead, it builds a deterministic daily course from reusable gameplay modules. That keeps the game fast, testable, and playable even if no provider is available.

## Core loop

1. Spawn in the prompt lobby.
2. Enter a sequence of generated obstacle stages.
3. Reach checkpoints to save progress for the current server session.
4. Survive stage modifiers such as disappearing context, false platforms, lava paths, and narrow beams.
5. Reach the final response pad and complete the run.

The same UTC day produces the same seed and therefore the same course layout for everyone running the same build.

## Identity

The AI theme is expressed through gameplay rather than requiring a chatbot:

- **Hallucination** - visually convincing platforms may not be real.
- **Context Window** - tiles disappear after being used.
- **Overconfident Output** - apparently simple paths contain unsafe choices.
- **Token Limit** - compact precision jumps with little room for error.
- **Prompt Drift** - the generated stage style changes during a run.

A later version can optionally accept validated level recipes from an AI service, but the local generator remains the fallback and source of truth for legal gameplay geometry.

## Project layout

The project uses Rojo 7 style project mapping:

```text
gptblox/
  default.project.json
  src/
    ReplicatedStorage/
    ServerScriptService/
    ServerStorage/
    StarterPlayer/StarterPlayerScripts/
```

Roblox currently uses Luau for scripting, and server-side game logic belongs in locations such as `ServerScriptService`. The current project keeps progression and course state on the server.

## Running in Roblox Studio

1. Install Rojo 7 and the matching Roblox Studio plugin.
2. From this directory, run `rojo serve`.
3. Open a blank place in Roblox Studio.
4. Connect the Rojo plugin to the local server.
5. Start Play or Start Server.

To build a place file without live sync:

```bash
rojo build -o gptblox.rbxlx
```

Do not commit generated place files unless there is an explicit reason to do so.

## MVP status

Implemented in the initial scaffold:

- deterministic daily seed
- server-generated course
- several obstacle templates
- hallucination/fake-platform stage
- disappearing platforms
- kill floor and lava hazards
- checkpoints and respawn
- run counter
- lightweight client HUD

Not yet implemented:

- persistence between servers
- cosmetics/rewards
- matchmaking/lobby queues
- player-authored prompts
- external AI-generated level recipes
- monetization
