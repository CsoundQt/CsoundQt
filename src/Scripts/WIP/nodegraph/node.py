
import random
from copy import copy

print "Test"

class SwitchModes:
    Next = 1
    NextByParent = 2
    All = 3
    Random = 4

class TimingMode:
    Beat = 1
    Sample = 2
    Seconds = 3

class Connector:
    def _init__(self, nextNode, angle = 90, distance = 1, 
                distanceMode = TimingMode.Beat,
                breakPoints = []):
        """  Connector """
        self._nextNode = nextNode
        self._angle = angle
        self._distance = distance
        self._distanceMode = distanceMode
        self._breakPoints = breakPoints
        self._remainingSteps = distance

    def setAngle(self, angle):
        self._angle = angle

    def setDistance(self, distance):
        self._distance = distance

    def setDistanceMode(self, mode):
        self._distanceMode = mode

    def setBreakpoint(self, fraction, rotation, index=None):
        if index == None:
            self._breakPoints = [[fraction, rotation]]
        else:
            self._breakPoints[index] = [fraction, rotation]

    def appendBreakpoint(self, fraction, rotation):
        self._breakPoints.append([fraction,rotation])

    def traverse(self, distance):
        self._remainingSteps -= distance
        residue = -self._remainingSteps
        products = None
        connectors = None
        if residue >= 0:
            self._remainingSteps = self._distance
            products = nextNode.getProducts()
            innerConnectors = nextNode.getNextConnectors()
            for connector in innerConnectors:
                (innerProducts, connectors) = connector.traverse(residue)
                products += innerProducts;
            connectors = innerConnectors;
        return (product, connectors)

    def reset(self):
        self._remainingSteps = self._distance

    @property
    def angle(self):
        """float. Starting angle of connector.""" 
        return self._angle
    @angle.setter
    def angle(self, x): self.setAngle(x) 

    @property
    def distance(self):
        """float. Total distance of connector.""" 
        return self._distance
    @distance.setter
    def distance(self, x): self.setDistance(x) 

class Node:
    def __init__(self):
        """ Node """
        self._productList = []
        self._productSwitchMode = SwitchModes.Next
        self._currentProduct = 0
        self._connectors = []
        self._nodeConnectorMode = SwitchModes.Next
        self._nextConnectorIndex = 0

    def getProducts(self):
        for connector in self._connectors:
            connector.reset()
        return None

    def getNextConnectors(self):
        connectors = []
        if len(self._connectors) == 0:
            return None
        if self._nodeConnectorMode == SwitchModes.Next:
            connectors = [copy(self._connectors[self._nextConnectorIndex])]
            self._nextConnectorIndex += 1
            self._nextConnectorIndex %= len(self._connectors)
        elif self._nodeConnectorMode == SwitchModes.NextByParent:
            #TODO implement
            connectors = [copy(self._connectors[self._nextConnectorIndex])]
            self._nextConnectorIndex += 1
            self._nextConnectorIndex %= len(self._connectors)
        elif self._nodeConnectorMode == SwitchModes.All:
            connectors = [copy(self._connectors)]
        elif self._nodeConnectorMode == SwitchModes.Random:
            randIndex = random.randint(0, len(self._connectors) - 1 )
            connectors = [copy(self._connectors[randIndex])]
        return connectors
 

class NodeTraverser:
    def __init__(self, startNode):
        """ NodeTraverser """
        self._startNode = startNode
        self._remaining
        self._currentNodes = startNode
        
        

