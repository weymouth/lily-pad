---
title: 'LilyPad: Real-time two-dimensional fluid/structure interaction simulations written in Processing'
tags:
  - computational fluid dynamics
  - fluid structure interaction
  - Processing Language
authors:
 - name: Gabriel D Weymouth
   orcid: 0000-0001-5080-5016
   affiliation: 1
 - name: Audrey Maertens
   orcid: 0000-0001-6409-3419
   affiliation: 2
 - name: Jacob Izraelevitz
   orcid: 0000-0002-1555-9136
   affiliation: 3
 - name: James Schulmeister
   orcid: 0000-0002-0334-4656
   affiliation: 4
affiliations:
 - name: University of Southampton
   index: 1
 - name: École Polytechnique Fédérale de Lausanne
   index: 2
 - name: Jet Propulsion Laboratory
   index: 3
 - name: Creare LLC
   index: 4
date: 17 July 2017
bibliography: paper.bib
---

# Summary

Lily Pad was developed in 2009 to fill the need for a simple-to-use computational fluid dynamics (CFD) tool for researchers working in unsteady fluid dynamics and fluid structure interactions. Standard CFD solvers require extensive training before they can be used because hundreds of parameters, including turbulence models and numerical grid parameterizations, must be properly set before the results can be trusted. Compounding this is the fact that there is no direct feedback to quickly let users know when they have made a mistake. Open source CFD solvers such as OpenFOAM [www.openfoam.org] provide a free and adaptable alternative to standard engineering software, but do not alleviate these fundamental issues.

Lily Pad addresses the need to lower the barrier to CFD in research by adopting simple high-speed methods, utilizing modern programming features and environments, and giving immediate visual feed-back to the user. Lily Pad simulates the full two-dimensional Navier-Stokes equations, but most of the complications plaguing CFD are avoided by immersing solid bodies into the fluid domain using the Boundary Data Immersion Method [@Maertens2015] on a uniform computational grid. Lily Pad is written using Processing Language [https://processing.org/] which is multi-platform and comes bundled with a development environment capable of handling run-time feedback from the user's mouse or keyboard. 

Lily Pad's simple and fast usage has enabled many users with no previous CFD experience to address open research problems in unsteady fluid mechanics; for example, how a bird can produce lift and drag during perching [@Polet2015], how spinning cylinders can eliminate drag on a bluff body [@Schulmeister2017], and how a tandem flapping foils (such as used by a plesiosaur) can increase thrust [@Muscutt2017]. At modest resolution, the simulation speed is sufficient to run simulations in real-time and the user can interact with the solid mechanical elements to adapt the flow. This makes Lily Pad ideal for quickly testing out research concepts and use in engineering education and outreach activities [http://edition.cnn.com/videos/tv/2015/03/11/spc-mainsail-design-special-b.cnn].

# References
