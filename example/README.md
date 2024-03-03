# MatterReplication Example

Minimal example using MatterReplication that will:

1. Assign a Model component to each Player
2. Spawn a ball every 5 seconds

For both of these cases all entities and components are replicated to clients.

To try out the example, you can run `rojo serve` from this directory and sync to an experience, or run `rojo build -o MatterReplicationExample.rbxl` to create a place file.

Make sure to run `wally install` from the root of the repo first, otherwise the build will fail.
