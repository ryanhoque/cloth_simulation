import numpy as np
from cloth import *

"""
A Tensioner grabs a circular region of cloth and fixes it in place.
It can then tug on the cloth in a particular direction.
"""
class Tensioner(object):

    def __init__(self, x, y, cloth, max_displacement=False):
        self.x, self.y = x, y
        self.origx, self.origy = x, y
        self.dz = 0
        self.cloth = cloth
        self.grabbed_pts = []
        cloth.add_tensioner(self)
        self.pin_position(x, y)  # Pin in place!
        if max_displacement:
            self.max_displacement = max_displacement
        else:
            self.max_displacement = float('inf')


    def pin_position(self, x, y):
        """Grab a position on the cloth and pin it in place.
        
        It pins points within a small radius, so in the visual it looks like a
        circular set of points moving around.
        
        This is why the points have z-axis 0 because we make it `pt.pinned`,
        like the top and bottom rows of the cloth. Note that this is a hard
        threshold constraint.
        """
        for pt in self.cloth.pts:
            if abs((pt.x - x) ** 2 + (pt.y - y) ** 2) < 1000:
                pt.pinned = True
                self.grabbed_pts.append(pt)

    def pin_points(self, pts):
        """Grab specific points given their object references.
        """
        for pt in self.cloth.pts:
            if pt in pts:
                pt.pinned = True
                self.grabbed_pts.append(pt)


    def unpin_position(self):
        """Let go of a grabbed position, and remove the current tensioner.
        """
        if len(self.grabbed_pts) == 0:
            print("Note: attemtping to unpin a tensioner that has no grabbed points...")
        for pt in self.grabbed_pts:
            pt.pinned = False
        self.grabbed_pts = []
        self.cloth.remove_tensioner(self)


    def tension(self, x, y, z=0):
        """Tug on the grabbed area in a direction.

        (I think direction vector is (x,y) ... by default also assumes a 2D
        plane so the tensioning keeps z constant?)

        Will adjust self.x and self.y for current tensioner, but we always have
        the original spot origx, origy.  Ah, if norm of change exceeds
        displacement we don't change anything.  But, max_displacement=False by
        default.

        For the grabbed points, the same as the points close to the current
        tensioner, we extract the (x,y,z) values and increment by the tension,
        after setting those to be previous (x,y,z) of course.
        """
        _diff = [self.x - self.origx + x, self.y - self.origy + y, self.dz + z]
        if np.linalg.norm(_diff) > self.max_displacement:
            return
        for pt in self.grabbed_pts:
            pt.px, pt.py, pt.pz = pt.x, pt.y, pt.z
            pt.x = x + pt.x
            pt.y = y + pt.y
            pt.z = z + pt.z
            self.dz += z
        self.x += x
        self.y += y


    @property
    def displacement(self):
        """Displacement from the original grabbing position
        """
        return np.array((self.x - self.origx, self.y - self.origy, self.dz))
    
