# Animation Frame Picker for Godot

![Imgur](https://i.imgur.com/32I4EVb.png)
</p>A Godot Engine add-on made by AniMesuro that adds a Frame Picker functionality for 2D Animation,
allowing for more efficient keyframing on an animation track.

# Table of Contents
- [Animation Frame Picker for Godot](#animation-frame-picker-for-godot)
- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Screenshots](#screenshots)
  - [Frame Picker](#frame-picker)
  - [Tool in use](#tool-in-use)
- [Videos](#videos)
- [Integrations](#integrations)
  - [Posepal](#posepal)
- [Disclaimer](#disclaimer)
- [Bug Report](#bug-report)

# Usage
The plugin adds a "Frame Picker" control to the second Upper Left Dock.
The Frame Picker requires 2 nodes in the tree: AnimationPlayer and AnimatedSprite.

1. Select an AnimatedSprite. (You can also select the selected one by right clicking)
2. Select an Animation. 
3. Select the AnimationPlayer (This should select the AnimationPlayer in Editor automatically)
4. Select the Animation from AnimationPlayer on the track editor.
5. Done! Move the Timeline cursor to the desired time and press the desired frame on the FramePicker. This will keyframe at the selected time.

> If you want to preview how a frame would look in a scene, right clicking the preview will apply it without keying.
# Screenshots

## Frame Picker
![Imgur](https://i.imgur.com/NbbCUiK.png)

## Tool in use
![Imgur](https://i.imgur.com/DVivtOA.png)

# Videos

[![Demo](http://i3.ytimg.com/vi/CtEqO24e708/maxresdefault.jpg)](https://www.youtube.com/watch?v=CtEqO24e708)
</p>Video Demo of Frame Picker add-on in use on a Godot project.

# Integrations

## Posepal

Frame Picker supports Posepal if the two versions are compatible.</p>
When editing a pose, the PoseAnimationPlayer will be selected at the Frame Picker dock, allowing the frame palette to help keying frame data for the pose. 

# Disclaimer
It's advisable you configure the SpriteFrames BEFORE keyframing using the Frame Picker. Any frame you remove from SpriteFrames could make a frame key on the animation track invalid (frame > frame_count)

Deleting an AnimatedSprite:animation track will emit a ton of errors because the AnimatedSprite frames will be orphans of animation.
Instead try to delete the AnimatedSprite:frame track first or disable the AnimatedSprite:animation track.

> Frame Picker doesn't hold any warranty for any issue and bug that may break your scene. It is always advisable that you backup your project. I don't assume any responsibility for any possible corruption or deletion of your animations.

# Bug Report
If you encounter any errors, try opening Godot's Debug Console on Windows or start Godot from the terminal and replicate the problem.
When reporting an issue, make sure to include any errors printed there.
