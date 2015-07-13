# The RJSDAQ
## A React Workshop

React is a Javascript library for building user interfaces that challenges some fundamental assumptions about how user interfaces should be built. In this workshop, you will learn to "think in React," as you build an interactive, data-driven, client-server web application in the browser.

First, we will learn what's distinctive about the React approach, and how we can benefit from it. Next, we will learn how React components are built, how they operate, how they communicate with each other, and how to test them. Along the way, in pairs or small groups, we will laugh, cry, scream, and cheer, but ultimately build some working software, the React Way.

### Sign up

If you would like to attend this workshop, and can be in Sacramento, CA on Saturday, July 18th, 2015, [sign up](https://ti.to/sacjs/reactjs-workshop).

### Prerequisites

**Materials**: Bring a laptop with Chrome and your favorite text editor. For the full experience, have Node/NPM installed.

**Knowledge**: You should be familiar with HTML, and one of either Coffeescript or Javascript.

### Setting up

The interface development team has produced plain HTML/CSS ready to be integrated, and the infrastructure team has set up a development environment for you. To set this up on your machine, you need to clone the repository, install some npm modules, and run the client:

    git clone --recursive git@github.com:steveluscher/react-rjsdaq-workshop.git
    cd react-rjsdaq-workshop
    cd client
    npm install
    npm start

You might also need to run the server, if a running one isn't available. Open a new terminal at the root of the repository, and run the server:

    cd server
    npm install
    npm start

Open the `client` directory in your favorite editor, visit <http://localhost:3000>, and get to work!

### Syllabus

#### 1. Why React?

This unit will equip students to:

* Recognize more or less performant approaches to updating the DOM
* Describe the high-level architecture of React
* Explain the relationship between the React engine and the Doom 3 game engine
* Describe React's change reconciliation algorithm

Students will participate by:

* Running, modifying, and profiling a sample, data-driven React demo

#### 2. Learning to speak React

This unit will equip students to:

* Use _any_ combination of Javascript, Coffeescript, and JSX to write React components
* Write React using an in-browser Javascript/JSX compiler
* Write React using a build system
* Build a basic React component
* Configure and mount a React component into the DOM
* Unmount a React component from the DOM
* Update the ‘props’ of a mounted React component
* Rapidly prototype, share, and collaborate on React components using JSFiddle
* Debug a running React application with the React Developer Tools in Chrome
* Find and read the React documentation

Students will participate by:

* Building a "Hello World" level component using their preferred variant of Javascript
* Experimenting to discover the execution order of callbacks / component methods on mount, unmount, prop transitions, and state transitions.
* Experimenting to discover in which methods it is forbidden to cause a state update

#### 3. Reacting to changes in data

This unit will equip students to:

* Store and update data on the client-side, using an immutable data structure
* Construct a complex UI through the composition of many small components
* Recognize which data should become ‘props’ of a component, and which belongs in its ‘state’
* Perform asynchronous updates to a React component's state
* Interact with the DOM using React ‘refs’
* Leverage the ‘lifecycle’ methods that get called when a component:
  * Mounts
  * Unmounts
  * Receives new props
  * Receives updated state
* Avoid modifying a component's state in illegal ways, or at illegal times

Students will participate by:

* Building a data-driven, client-server data visualization

#### 4. Reacting to user input

This unit will equip students to:

* React to user input events
* React to DOM events
* Link form controls with a component's state
* Enforce constraints on user input
* Use ‘keys’ to maintain the datum/component relationship when reordering React components

Students will participate by:

* Adding interactivity and user-generated content to the app from the previous section

#### 5. Advanced component architecture

This unit will equip students to:

* Share common component traits through mixins
* Define and enforce component interfaces through the use of prop validation
* Communicate between components using delegation
* Communicate between components using a message center

Students will participate by:

* Refactoring their app from the previous section

#### 6. Performance

This unit will equip students to:

* Use heuristics to optimize a React app
* Prerender and cache a React component on the server-side

Students will participate by:

* Optimizing their app from the previous section

#### 7. Testing React components (optional)

This unit will equip students to:

* Test the render output of a React component
* Simulate DOM events to test a React component

Students will participate by:

* Writing tests against their app from the previous section

### About the facilitator

Steven Luscher builds web and mobile applications using HTML, CSS, Javascript, Ruby, and Objective-C. En-route to becoming a polyglot coder, he made stops along the way to pursue formal education in graphic design, mathematics, and pedagogy; experiences which have served him well in the area of web application development.

In 2013, he delivered a [conference talk about React](https://github.com/steveluscher/react-supervanjs-2013) at Super VanJS. He currently works on the Relay team at Facebook, and teaches React to new employees.
