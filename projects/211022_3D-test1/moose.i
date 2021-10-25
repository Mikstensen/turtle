#
# Simulation of an iron-chromium alloy using simple code and a test set of
# initial conditions.
#

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 8
  xmin = 0
  xmax = 25
  ymin = 0
  ymax = 25
  zmin = 0
  zmax = 5
  uniform_refine = 3
[]

[Variables]
  [./c]   # Mole fraction of Cr (unitless)
    order = FIRST
    family = LAGRANGE
  [../]
  [./w]   # Chemical potential (eV/mol)
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  # Use a bounding box IC at equilibrium concentrations to make sure the
  # model behaves as expected.
  [./testIC]
    # type = BoundingBoxIC
    type = ConstantIC
    variable = c
    value = 0.823
    #x1 = 0
    #x2 = 25
    #y1 = 0
    #y2 = 25
    #z1 = 2.5
    #z2 = 5
    #inside = 0.823
    #outside = 0.236
    #inside = 0.236
    #outside = 0.823
  [../]
[]

[Functions]
  [top_function]
    type = ParsedFunction
    value = (0.823-0.236)*(sin(0.000001*pi*t))^2+0.236
    #value = (0.823-0.236)*(0.5*tanh(0.00001*pi*t)+0.5)+0.236
    #value = 0.823-(0.823-0.236)*(0.5*tanh(0.00001*pi*t)+0.5)
  []
[]
[BCs]
  [Periodic]
    [x]
        variable = c
        auto_direction= 'x'
    []
    [y]
        variable = c
        auto_direction= 'y'
    []
  []
  [i1]
    type = DirichletBC  # Simple u=value BC
    #type = NeumannBC 
    # type = FunctionDirichletBC
    variable = c # Variable tw be set
    boundary = front     # Name of a sideset in the mesh
    #value = 0.823        # (Pa) From Figure 2 from paper.  First data point for 1mm spheres.
    value = 0.236        # (Pa) From Figure 2 from paper.  First data point for 1mm spheres.
    #value = 0        # (Pa) From Figure 2 from paper.  First data point for 1mm spheres.
    #value = 1e-7
    #function = top_function
  []
  [i3]
    #type = DirichletBC  # Simple u=value BC
    type = NeumannBC 
    variable = c # Variable tw be set
    boundary = front     # Name of a sideset in the mesh
    value = -1e-6
  []
  [i2]
    #type = DirichletBC
    type = NeumannBC
    #variable = c
    variable = c
    boundary = back
    #value = 0.236        # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
    #value = 0.823        # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
    #value = 1e-4       # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
    value = 0       # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
  []
[]


[Kernels]
  # See wiki page "Developing Phase Field Models" for more information on Split
  # Cahn-Hilliard equation kernels.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/DevelopingModels/
  [./w_dot]
    variable = w
    v = c
    type = CoupledTimeDerivative
  [../]
  [./coupled_res]
    variable = w
    type = SplitCHWRes
    mob_name = M
  [../]
  [./coupled_parsed]
    variable = c
    type = SplitCHParsed
    f_name = f_loc
    kappa_name = kappa_c
    w = w
  [../]
[]


[Materials]
  # d is a scaling factor that makes it easier for the solution to converge
  # without changing the results. It is defined in each of the materials and
  # must have the same value in each one.
  [./constants]
    # Define constant values kappa_c and M. Eventually M will be replaced with
    # an equation rather than a constant.
    type = GenericFunctionMaterial
    prop_names = 'kappa_c M'
    prop_values = '8.125e-16*6.24150934e+18*1e+09^2*1e-27
                   2.2841e-19*1e+09^2/6.24150934e+18/1e-27'
                   # 2.2841e-26*1e+09^2/6.24150934e+18/1e-27'
                   # kappa_c*eV_J*nm_m^2*d
                   # M*nm_m^2/eV_J/d
  [../]
  [./local_energy]
    # Defines the function for the local free energy density as given in the
    # problem, then converts units and adds scaling factor.
    type = DerivativeParsedMaterial
    f_name = f_loc
    args = c
    constant_names = 'A   B   C   D   E   F   G  eV_J  d'
    constant_expressions = '-2.446831e+04 -2.827533e+04 4.167994e+03 7.052907e+03
                            1.208993e+04 2.568625e+03 -2.354293e+03
                            6.24150934e+18 1e-27'
    function = 'eV_J*d*(A*c+B*(1-c)+C*c*log(c)+D*(1-c)*log(1-c)+
                E*c*(1-c)+F*c*(1-c)*(2*c-1)+G*c*(1-c)*(2*c-1)^2)'
    derivative_order = 2
  [../]
[]

[Postprocessors]
  [./evaluations]           # Cumulative residual calculations for simulation
    type = NumResidualEvaluations
  [../]
  [./elapsed]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  [../]
[]

[Preconditioning]
  # Preconditioning is required for Newton's method. See wiki page "Solving
  # Phase Field Models" for more information.
  # http://mooseframework.org/wiki/PhysicsModules/PhaseField/SolvingModels/
  [./coupled]
    type = SMP
    full = true
  [../]
[]


[Adaptivity]
  marker = error_frac
  max_h_level = 3
  [Indicators]
    [c_jump]
      type = GradientJumpIndicator
      variable = c
    []
  []
  [Markers]
    [error_frac]
      type = ErrorFractionMarker
      coarsen = 0.15
      indicator = c_jump
      refine = 0.7
    []
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  automatic_scaling = true
  l_max_its = 30
  l_tol = 1e-6
  nl_max_its = 50
  nl_abs_tol = 1e-9
  end_time = 8640000   # 100 days.
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm 31 preonly ilu 1'
  [./TimeStepper]
    # Turn on time stepping
    type = IterationAdaptiveDT
    dt = 10
    cutback_factor = 0.8
    growth_factor = 1.5
    optimal_iterations = 7
  [../]
[]

#[Debug]
#  show_var_residual_norms = true
#[]

[Outputs]
  exodus = true
  #console = true
  #csv = true
  #[./console]
  #   type = Console
  #  max_rows = 10
  #[../]
[]
