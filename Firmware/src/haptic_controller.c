/*
 * Copyright (C) 2017 EPFL-LSRO (Laboratoire de Systemes Robotiques).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "haptic_controller.h"
#include "communication.h"
#include "drivers/adc.h"
#include "drivers/incr_encoder.h"
#include "drivers/hall.h"
#include "drivers/callback_timers.h"
#include "lib/utils.h"
#include "torque_regulator.h"

#define DEFAULT_HAPTIC_CONTROLLER_PERIOD 350 // Default control loop period [us].

volatile uint32_t  hapt_timestamp; // Time base of the controller, also used to timestamp the samples sent by streaming [us].
volatile float32_t force;

void hapt_Update(void);

/**
  * @brief Initializes the haptic controller.
  */
void hapt_Init(void)
{
    hapt_timestamp = 0;
    force = 0.0f;

    // Make the timers call the update function periodically.
    cbt_SetHapticControllerTimer(hapt_Update, DEFAULT_HAPTIC_CONTROLLER_PERIOD);

    // Share some variables with the computer.
    comm_monitorUint32Func("timestep [us]", cbt_GetHapticControllerPeriod,
                           cbt_SetHapticControllerPeriod);
    comm_monitorFloat("force", (float32_t*)&force, READWRITE);
}

/**
  * @brief Updates the haptic controller state.
  */
void hapt_Update()
{
    float32_t hapt_motorTorque = 0.0f; // Motor torque [N.m].
    float32_t hapt_encoderPaddleAngle;
    float32_t motorShaftAngle;
    float32_t radius = 0.005;
    float32_t friction = 0.00068;
	float32_t g = 9.81;
	float32_t m = 0.075;
	float32_t l = 0.019;
    // Compute the dt (uncomment if you need it).
    //float32_t dt = ((float32_t)cbt_GetHapticControllerPeriod()) / 1000000.0f; // [s].

	motorShaftAngle = enc_GetPosition();
	hapt_encoderPaddleAngle = motorShaftAngle / REDUCTION_RATIO;

    // Increment the timestamp.
    hapt_timestamp += cbt_GetHapticControllerPeriod();
    hapt_motorTorque = radius*force + friction + (m*g*l*sin(hapt_encoderPaddleAngle*3.14f/180.0f)/REDUCTION_RATIO);

    if(hapt_encoderPaddleAngle<0)
    	hapt_motorTorque += 0.00003;

    // Compute the motor torque, and apply it.
    //hapt_motorTorque = 0.0f;
    torq_SetTorque(hapt_motorTorque);
}

