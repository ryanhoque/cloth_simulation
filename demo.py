"""
This script contains a demo that can be run out of the box.
If provided w/the 'manual' argument, the user can control position of the cutting tool.
If this file is modified, you don't need to re-compile/build the cython code.
"""
import matplotlib.pyplot as plt
import numpy as np
import sys
from cloth import *
from circlecloth import *
from mouse import *
from point import *
from constraint import *
from util import *
from mpl_toolkits.mplot3d import Axes3D
from gripper import Gripper


def cut(mouse):
    """If you want to let the cloth settle, just run `c.update()` before doing
    anything, as often as you want.

    Careful, changing width/height will add more points but not make it stable;
    the cloth 'collapses' ... need to investigate code?
    """
    circlex = 300
    circley = 300
    radius = 150 # only used for 'auto' code

    c = CircleCloth(mouse, width=50, height=50, elasticity=0.1, minimum_z=-50.0,
                    gravity=-100)
    grip = Gripper(cloth=c)

    # Simulate grabbing the gauze via tensioning
    # --------------------------------------------------------------------------
    # Daniel: _this_ is why the (300,300) point by default has z-coordinate of
    # 0, because we asssume we have a tool which pinched it at that point! If
    # you enable this, the cloth animation appears to 'shink' towards (300,300)
    # but it's actually just tension. Look at the 3D plot!
    # --------------------------------------------------------------------------
    #c.pin_position(circlex, circley)
    #tensioner = c.tensioners[0]

    # Use `plt.ion()` for interactive plots, requires `plt.pause(...)` later.
    nrows, ncols = 1, 2
    fig = plt.figure(figsize=(10*ncols,10*nrows))
    ax1 = fig.add_subplot(1, 2, 1)
    ax2 = fig.add_subplot(1, 2, 2, projection='3d')
    plt.ion()
    plt.tight_layout()
    cid = fig.canvas.mpl_connect('button_press_event', mouse.clicked)
    rid = fig.canvas.mpl_connect('button_release_event', mouse.released)
    mid = fig.canvas.mpl_connect('motion_notify_event', mouse.moved)

    for i in range(400):
        # Clear the figure
        if i % 10 == 0:
            print("Iteration", i)
        ax1.cla()
        ax2.cla()

        ## # ---------- Daniel: looks cool :-) ----------
        ## if i % 20 == 0:
        ##     print("adding tension...")
        ##     if i < 200:
        ##         tensioner.tension(x=0.5, y=0.5, z=0)
        ##     else:
        ##         tensioner.tension(x=-0.5, y=-0.5, z=0)

        # ----------------------------------------------------------------------
        # Re-insert the points, with appropriate colors. 2D AND 3D together.
        # ----------------------------------------------------------------------
        pts  = np.array([[p.x, p.y, p.z] for p in c.normalpts])
        cpts = np.array([[p.x, p.y, p.z] for p in c.shapepts])
        if len(pts) > 0:
            ax1.scatter(pts[:,0], pts[:,1], c='g')
            ax2.scatter(pts[:,0], pts[:,1], pts[:,2], c='g')
        if len(cpts) > 0:
            ax1.scatter(cpts[:,0], cpts[:,1], c='b')
            ax2.scatter(cpts[:,0], cpts[:,1], cpts[:,2], c='b')
        plt.pause(0.01)
        # ----------------------------------------------------------------------

        # Updates (+5 extra) to allow cloth to respond to environment.
        c.update()
        for j in range(5):
            c.update()

    ### simulate moving the mouse in a circle while cutting, overcut since no perception
    ##if auto:
    ##    if i < 150:
    ##        theta = 360.0/100.0 * i * np.pi / 180.0
    ##        x = radius * np.cos(theta)
    ##        y = radius * np.sin(theta)
    ##        mouse.move(x + circlex, y + circley)

    fig.canvas.mpl_disconnect(cid)
    fig.canvas.mpl_disconnect(mid)
    fig.canvas.mpl_disconnect(rid)


if __name__ == "__main__":
    # Originally mouse.down = True but I think it's better as False.
    mouse = Mouse()
    mouse.down = False
    mouse.button = 0

    cut(mouse)
