"""
An implementation of a mouse class, that can be updated/modified
to cut the cloth or disturb it. This can be used to interface with
a physical or virtual mouse.

Updates from mouse are only applied if `mouse.down=True`. We can make this true
by default but I think best to only do if we're clicking.
"""

class Mouse(object):

    def __init__(self, x=0, y=0, z=0, height_limit=False, down=False,
                 button=0, bounds=(600, 600, 800), influence=5, cut=10,
                 enable_cutting=True):
        self.down = down
        self.button = button
        self.x, self.y, self.z = x, y, z
        self.px, self.py, self.pz = x, y, z
        self.cut = cut
        self.influence = influence
        self.bounds=bounds
        if height_limit:
            self.height_limit = height_limit
        else:
            self.height_limit = float('inf')
        self.initial_params = [(x, y, z), self.height_limit, down, button]
        self.enable_cutting = enable_cutting


    def move(self, x, y, z=None):
        """ Move mouse to a position on the canvas.
        """
        if not z:
            z = self.z
        if 0 <= x <= self.bounds[0] and 0 <= y <= self.bounds[1] and \
                    -self.bounds[2] <= z <= self.bounds[2]:
            self.px, self.py = self.x, self.y
            self.x, self.y = x, y
        else:
            pass
            #print("Invalid location: Out of Bounds.")


    def clicked(self, event):
        """ Handles click events of the mouse.
        """
        if self.enable_cutting:
            self.down = True


    def released(self, event):
        """ Handles mouse release events.
        """
        self.down = False


    def moved(self, event):
        """ Handles mouse move events.
        """
        self.move(event.xdata, event.ydata)


    def reset(self):
        """ Resets the mouse object to its initial state.
        """
        pos = self.initial_params[0]
        self.x, self.y, self.z = pos
        self.px, self.py, self.pz = pos
        self.height_limit = self.initial_params[1]
        self.down = self.initial_params[2]
        self.button = self.initial_params[3]
