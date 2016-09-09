classdef arduinoController < handle
    properties
        arduinoObj       % arduino object
        servo1           % base servo
        angle1 = 0;      % angle for base servo
        servo2
        angle2 = 0;
		servo3
		angle3 = 0;  
		
		SavedTrj = [];   % Saved trajetory to replay
	end
	
	properties (SetAccess = ? armUI)
		isconnected = false;
	end
    
	properties (Dependent)
		EndPointData = [];
	end
	
    methods
		
		function copyAngle(this, simulator)
			this.angle1 = simulator.theta1;
			this.angle2 = simulator.theta2;
			this.angle3 = simulator.theta3;
		end
		
        function result = connectArduino(this)
            % Create the arduino object
			if this.isconnected
				return;
			end
			
			try
				this.arduinoObj = arduino('com4','uno');
				this.servo1 = this.arduinoObj.servo('D9');
				this.servo2 = this.arduinoObj.servo('D10');
				this.isconnected = true;		
				msgbox('Sucessfully connected')
				update(this);
			catch Ex
				errordlg('Connection Failed!')
				this.isconnected = false;
			end
			result = this.isconnected;
		end
		
		function disconnectArduino(this)
			if this.isconnected
				delete(this.arduinoObj);
				delete(this.servo1);
				delete(this.servo2);
				msgbox('Disconnected successfully!')
			end
		end
        
        function update(this)
			if this.isconnected
				this.servo1.writePosition(this.angle1/pi);
				this.servo2.writePosition(this.angle2/pi);
			end
		end
		
		
		% -- Trajectories
		function addTrjPoint(this, val)
			assert(all(size(val) == [1 3]));
			this.SavedTrj = [this.SavedTrj ; val];
		end
		
		function clearSavedTrj(this)
			this.SavedTrj = [];
		end
		
		function loadTrj(this, trj)
			assert(size(trj,2) == 3);
			this.SavedTrj = trj;
		end
		
		function val = get.EndPointData(this)
			val = ones(size(this.SavedTrj));
			for ct = 1:size(val,1)
				val(ct,:) = mraSimulator.getEndPointXYZ(this.SavedTrj(ct,:));
			end
		end
		
		% Export trajectory to baseworkspace
		function exportTrj(this)			
			assignin('base', 'microRoboticArmTrj', this.SavedTrj);
		end
        
%         function replay(this, dt)
%             % Replay saved trajectory
% 			if this.isconnected
% 				for ct = 1:numel(this.savedTrj)
% 					this.angle1 = this.savedTrj(ct);
% 					update(this);
% 					pause(dt);
% 				end
% 			end
%         end
    end
end