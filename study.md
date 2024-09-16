# Neural Networks


## MuscleNN
`-> ray_env.py -> class MuscleLearner:`
## SimulationNN
RL part
- Nothing special here I think...

`-> ray_env.py -> X`

`-> ray_model.py -> class SimulationNN_Ray(TorchModelV2, SimulationNN):`

`-> ray_model.py -> class PolicyNN:`
## RefNN
`-> ray_env.py -> class RefLearner:`
## MarginalNN
`-> ray_env.py -> class MarginalLearner:`

# Environment.cpp

## mIsTorqueSymMode
```cpp
if (abs(maxv[i] - minv[i]) > 1E-6)
{
    if (0.5 < GetPhase() && mIsTorqueSymMode)
    {
        proj_muscle_param[idx++] = param[i + 1];
        proj_muscle_param[idx++] = param[i];
    }
    else
    {
        proj_muscle_param[idx++] = param[i];
        proj_muscle_param[idx++] = param[i + 1];
    }
}
```

## mIsMuscleSymMode
```cpp
if (GetPhase() > 0.5 && mIsMuscleSymMode)
{
    for (int i = 0; i < a.rows(); i += 2)
    {
        if (mUseExcitation && !mIsNew)
        {
            mExcitationLevels[i] = a[i + 1];
            mExcitationLevels[i + 1] = a[i];
        }
        else
        {
            mActivationLevels[i] = a[i + 1];
            mActivationLevels[i + 1] = a[i];
        }
    }
}
else
{
    if (mUseExcitation && !mIsNew)
        mExcitationLevels = a;
    else
        mActivationLevels = a;
}
```

## GetPhase()
```cpp
double
Environment::
	GetPhase()
{
	double t_phase = mCharacter->GetBVH()->GetMaxTime();

	return std::fmod(mLocalTime, t_phase) / t_phase;
}
```
BVH: BioVision Hierarchy..?