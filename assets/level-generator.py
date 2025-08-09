import json
import random

# Grid size in tiles
GRID_WIDTH = 10
GRID_HEIGHT = 8

# Possible movement directions
DIRECTIONS = ["l", "r", "u", "d"]

def random_code(num_segments=4, max_amount=5):
    """Generate a movement code like 'l.4-d.2-u.2-r.1' with no repeated directions."""
    moves = {d: 0 for d in DIRECTIONS}  # Track totals for each direction
    
    for _ in range(num_segments):
        dir_ = random.choice(DIRECTIONS)
        amt = random.randint(1, max_amount)
        moves[dir_] += amt  # Add to total for that direction
    
    # Remove any directions with 0 movement
    moves = {d: amt for d, amt in moves.items() if amt > 0}
    
    # Shuffle the order of directions
    ordered_dirs = list(moves.items())
    random.shuffle(ordered_dirs)
    
    # Build the string
    parts = [f"{d}.{amt}" for d, amt in ordered_dirs]
    return "-".join(parts)

def random_position():
    """Generate a random (x, y) grid position within bounds."""
    x = random.randint(0, GRID_WIDTH - 1)
    y = random.randint(0, GRID_HEIGHT - 1)
    return [x, y]

def generate_level():
    """Generate a single level JSON object."""
    return {
        "code": random_code(),
        "nextLevelPath": "stages/stage3",
        "playerPosition": random_position(),
        "keyPosition": random_position(),
        "doorPosition": random_position()
    }

if __name__ == "__main__":
    print(generate_level())
