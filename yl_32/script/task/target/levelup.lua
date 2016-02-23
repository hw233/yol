
local tb	= Task:GetTarget("PlayerLevelUp");
tb.szTargetName	= "PlayerLevelUp";
tb.REFRESH_FRAME	= 18 * 60;	-- zhengyuhua:����ˢ��Ƶ��(ԭ��һ����һ��)

function tb:Init(nLevel, szStaticDesc, szDynamicDesc)
	self.nLevel				= nLevel;
	self.szStaticDesc		= szStaticDesc;
	self.szDynamicDesc		= szDynamicDesc;
end;


--Ŀ�꿪��
function tb:Start()
		self.bDone		= 0;
		self:Register();
end;

--Ŀ�걣��
--�������������Id��nGroupId���Լ����ڱ�����ʼId��nStartTaskId�������汾Ŀ�������������
--����ʵ�ʴ���ı�������
function tb:Save(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- ���ﱣ���������Ժ���ʱ��������ͬ���ͻ���
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.me.pTask.SetTask(nGroupId, nStartTaskId, self.bDone, 1);
	
	return 1;
end;

--Ŀ������
--�������������Id��nGroupId���Լ����ڱ�����ʼId��nStartTaskId�������뱾Ŀ�������������
--����ʵ������ı�������
function tb:Load(nGroupId, nStartTaskId)	
	self.tbSaveTask	= {	-- ���ﱣ���������Ժ���ʱ��������ͬ���ͻ���
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.bDone		= self.me.pTask.GetTask(nGroupId, nStartTaskId);
	
	if (self.bDone ~= 1) then
		self:Register();
	end
	
	return 1;
end;

--����Ŀ���Ƿ���
function tb:IsDone()
	return self.bDone == 1;
end;

--����Ŀ������е��������ͻ��ˣ�
function tb:GetDesc()
	return self.szDynamicDesc;
end;


--����Ŀ��ľ�̬�������뵱ǰ��ҽ��е�����޹�
function tb:GetStaticDesc()
	return self.szStaticDesc;
end;


function tb:Close(szReason)
	self:UnRegister();
end;

function tb:Register()
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegister()
	if (MODULE_GAMESERVER and self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;


function tb:OnTimer()
	if (self.me.GetLevel() >= self.nLevel) then
		self.bDone = 1;
		
		local tbSaveTask	= self.tbSaveTask;
		if (MODULE_GAMESERVER and tbSaveTask) then	-- ����ͬ�����ͻ��ˣ�Ҫ��ͻ���ˢ��
			self.me.pTask.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
			KTask.SendRefresh(self.me, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
	
		
	
		self:UnRegister()	-- ��Ŀ����һ����ɺ󲻻�ʧЧ��
	
		self.tbTask:OnFinishOneTag();
	end
end
