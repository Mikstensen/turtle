//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "TurtleTestApp.h"
#include "TurtleApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
TurtleTestApp::validParams()
{
  InputParameters params = TurtleApp::validParams();
  return params;
}

TurtleTestApp::TurtleTestApp(InputParameters parameters) : MooseApp(parameters)
{
  TurtleTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

TurtleTestApp::~TurtleTestApp() {}

void
TurtleTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  TurtleApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"TurtleTestApp"});
    Registry::registerActionsTo(af, {"TurtleTestApp"});
  }
}

void
TurtleTestApp::registerApps()
{
  registerApp(TurtleApp);
  registerApp(TurtleTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
TurtleTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  TurtleTestApp::registerAll(f, af, s);
}
extern "C" void
TurtleTestApp__registerApps()
{
  TurtleTestApp::registerApps();
}
