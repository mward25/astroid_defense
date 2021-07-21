#include "godot_cpp_test.hpp"

using namespace godot;

void GodotCppTest::_register_methods()
{
	register_method("_process", &GodotCppTest::_process);
}

GodotCppTest::GodotCppTest()
{

}
GodotCppTest::~GodotCppTest()
{

}

void GodotCppTest::_init()
{
	time_passed = 0.0;
}

void GodotCppTest::_process(float delta)
{
	time_passed -= delta;

	Vector2 new_position = Vector2(10.0 + (10.0 * sin(time_passed * 2.0)), 10.0 + (10.0 * cos(time_passed * 1.5)));
	set_position(new_position);
}