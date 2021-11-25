# LuaClassSystem
My take (just for fun) on a Lua Class System

It is not really ideal for usage - it's main purpose was to learn from it and just for fun.

## How to use

A class can be defined with
```lua
MyClass = Class "MyClass"
```
afterwards, you're free to set fields and methods to it, ex.:
```lua
MyClass.myCounter = 0

function MyClass:resetCount()
  self.myCounter = 0
end

function MyClass:countUp()
  self.myCounter = self.myCounter + 1
end

function MyClass:constructor()
  self.myCounter = 0
end
```

you can also define a class like so:
```lua
MyClass = Class "MyClass" {
  myCounter = 0,
  myOtherField = "some string",
  countUp = function(self)
    self.myCounter = self.myCounter + 1
  end
}

-- or like so
MyClass = Class "MyClass" {
  myCounter = 0
}

function MyClass:countUp()
  self.myCounter = self.myCounter + 1
end

-- or
MyClass = Class("MyClass"){
  myCounter = 0
}
--...
```

To not provide any misunderstandings, upon setting the constructor field, it will not be part of the class table, instead, to get an object based on the class:
```lua
local myObject = MyClass(constructorArgs)
```

A class will need to have one field be set before it can be used for objects.

printing a class will print something like
`LuaClass<MyClass> 0x00000000`
whereas printing an oject will print something like
`LuaObject<MyClass> 0x00000000`

Additionally, to have a class extend upon another:
```lua
MyOtherClass = MyClass:extends("MyOtherClass")
```
and it will have access to the method super which is to be used with the class variable, like so for example:

```lua
Animal = Class "Animal" {
  age = 0
}

function Animal:constructor(age)
  self.age = tonumber(age)
end

-- Extended class
Human = Animal:extends "Human" {
  name = "None"
}

function Human:constructor(name, age)
  Human:super("constructor", self, age)
  self.name = tostring(name)
end
```

This little project's main purpose was to learn more about metamethods, less so for actually being used.

I've had my fair share of fun - and confusion from it. I also learned a lot!
