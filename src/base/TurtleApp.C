#include "TurtleApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
TurtleApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

TurtleApp::TurtleApp(InputParameters parameters) : MooseApp(parameters)
{
  TurtleApp::registerAll(_factory, _action_factory, _syntax);
}

TurtleApp::~TurtleApp() {}

void
TurtleApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"TurtleApp"});
  Registry::registerActionsTo(af, {"TurtleApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
TurtleApp::registerApps()
{
  registerApp(TurtleApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
TurtleApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TurtleApp::registerAll(f, af, s);
}
extern "C" void
TurtleApp__registerApps()
{
  TurtleApp::registerApps();
}
