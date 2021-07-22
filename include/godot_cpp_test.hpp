#ifndef godot_cpp_test_HPP
#define godot_cpp_test_HPP

#include <Godot.hpp>
#include <Sprite.hpp>


namespace godot
{
	class GodotCppTest : public Sprite
	{
		GODOT_CLASS(GodotCppTest, Sprite)
	private:
		float time_passed;
	
	public:
		static void _register_methods();

		GodotCppTest();
		~GodotCppTest();

		void _init();

		void _process(float delta);
	};
}
#endif