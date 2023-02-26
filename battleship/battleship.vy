''' A simple implementation of battleship in Vyper '''

# NOTE: The provided code is only a suggestion
# You can change all of this code (as long as the ABI stays the same)

NUM_PIECES: constant(uint32) = 5
BOARD_SIZE: constant(uint32) = 5

# What phase of the game are we in ?
# Start with SET and end with END
PHASE_SET: constant(int32) = 0
PHASE_SHOOT: constant(int32) = 1
PHASE_END: constant(int32) = 2

# Each player has a 5-by-5 board
# The field track where the player's boats are located and what fields were hit
# Player should not be allowed to shoot the same field twice, even if it is empty
FIELD_EMPTY: constant(int32) = 0
FIELD_BOAT: constant(int32) = 1
FIELD_HIT: constant(int32) = 2

players: immutable(address[2])
winner: int32

player1_board: int32[BOARD_SIZE][BOARD_SIZE]
player2_board: int32[BOARD_SIZE][BOARD_SIZE]
player1_count: uint32
player2_count: uint32
player1_hits: uint32
player2_hits: uint32

# Which player has the next turn? Only used during the SHOOT phase
next_player: uint32

# Which phase of the game is it?
phase: int32

@external
def __init__(player1: address, player2: address):
    players = [player1, player2]
    self.next_player = 0
    self.phase = PHASE_SET
    self.winner = -1
    for i in range (BOARD_SIZE):
        for j in range(BOARD_SIZE):
            self.player1_board[i][j] = FIELD_EMPTY
            self.player2_board[i][j] = FIELD_EMPTY
    self.player1_count = 0
    self.player2_count = 0

@external
def set_field(pos_x: uint32, pos_y: uint32):
    '''
    Sets a ship at the specified coordinates
    This should only be allowed in the initial phase of the game

    Players are allowed to call this out of order,
    but at most NUM_PIECES times
    '''
    if self.phase != PHASE_SET:
        raise "Wrong phase"

    if pos_x >= BOARD_SIZE or pos_y >= BOARD_SIZE:
        raise "Position out of bounds"

    if(msg.sender == players[0]):
        if(self.player1_count>=NUM_PIECES):
            raise "Already set 5 pieces!"
        elif(self.player1_board[pos_x][pos_y]!=FIELD_EMPTY):
            raise "Boat is already set here!"
        else:
            self.player1_board[pos_x][pos_y]=FIELD_BOAT
            self.player1_count+=1

    elif(msg.sender == players[1]):
        if(self.player2_count>=NUM_PIECES):
            raise "Already set 5 pieces!"
        elif(self.player2_board[pos_x][pos_y]!=FIELD_EMPTY):
            raise "Boat is already set here!"
        else:
            self.player2_board[pos_x][pos_y]=FIELD_BOAT
            self.player2_count+=1

    else:
        raise "Third party cannot set fields!"
    
    if(self.player1_count>=NUM_PIECES and self.player2_count>=NUM_PIECES):
        self.phase=PHASE_SHOOT
        self.player1_hits = 0
        self.player2_hits = 0

@external
def shoot(pos_x: uint32, pos_y: uint32):
    '''
    Shoot a specific field on the other players board
    This should only be allowed if it is the calling player's turn and only during the SHOOT phase
    '''

    if pos_x >= BOARD_SIZE or pos_y >= BOARD_SIZE:
        raise "Position out of bounds"

    if self.phase != PHASE_SHOOT:
        raise "Wrong phase"

    if (msg.sender!=players[self.next_player]):
        raise "Not your chance to shoot!"
    
    if(msg.sender==players[0]):
        if(self.player2_board[pos_x][pos_y]==FIELD_HIT):
            raise "You've already shot this!"
        if(self.player2_board[pos_x][pos_y]==FIELD_BOAT):
            self.player1_hits+=1
        self.player2_board[pos_x][pos_y]=FIELD_HIT

    if(msg.sender==players[1]):
        if(self.player1_board[pos_x][pos_y]==FIELD_HIT):
            raise "You've already shot this!"
        if(self.player1_board[pos_x][pos_y]==FIELD_BOAT):
            self.player2_hits+=1
        self.player1_board[pos_x][pos_y]=FIELD_HIT

    self.next_player = (self.next_player+1)%2

    if(self.player1_hits>=5):
        self.winner=0
        self.phase = PHASE_END
    
    if(self.player2_hits>=5):
        self.winner=1
        self.phase = PHASE_END

@external
@view
def has_winner() -> bool:
    return self.phase == PHASE_END

@external
@view
def get_winner() -> address:
    ''' Returns the address of the winner's account '''

    # Raise an error if no one won yet
    if(self.winner==-1):
        raise "No one won yet"
    
    return players[self.winner]