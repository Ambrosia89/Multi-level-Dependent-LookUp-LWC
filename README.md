# Multi-level-Dependent-LookUp-LWC

This is a custom lookup lightning web component. It has a dual component architerture in a parent-child LWC component set up. This component is abstract and can be used for any parent-child pair or on its own.

(1) When the component is used without any parent record Id property, the component behaves like a classic lookup component
(2) When the component is used with a parent record Id property, the component return only records related to the parent object
(3) When the child record is an opportunity, there is an otion to retrun (a) open opportunities only, or (b) all opportunities
      
