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

Lily Pad is a computational fluid dynamics (CFD) solver using Processing Language [https://processing.org/]. The goal of Lily Pad is to lower the barrier to CFD by adopting simple high-speed methods, utilizing modern programming features and environments, and giving immediate visual feed-back to the user. The resulting software focuses on the fluid dynamics instead of the computation, making it useful for both education and research.

Lily Pad simulates the full two-dimensional Navier-Stokes equations, but most of the complications plaguing CFD are avoided by immersing solid bodies into the fluid domain using the Boundary Data Immersion Method [https://doi.org/10.1016/j.cma.2014.09.007]. This enables arbitrary structural dynamics to be simulated with ease, such as multiple interacting flexible size-changing bodies. The Processing Development Environment is used to integrate the writing, testing, and usage modes into a single platform. At modest resolution, the simulation speed is sufficient to run simulations in real-time and the user can interact with the solid mechanical elements to adapt the flow.

Lily Pad is open source and available at [https://github.com/weymouth/lily-pad] and has a DOI [https://doi.org/10.5281/zenodo.16065]. It has been used in dozens of engineering outreach activities [http://edition.cnn.com/videos/tv/2015/03/11/spc-mainsail-design-special-b.cnn] and student projects, many of which have been published in top peer review journals [https://doi.org/10.1017/jfm.2015.61, https://doi.org/10.1017/jfm.2017.395].

# References
