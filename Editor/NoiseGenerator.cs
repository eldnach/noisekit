using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System.Runtime.InteropServices;
using UnityEditor;


public class NoiseGenerator 
{
    public int id;

    RenderTexture outputTex;
    RenderTexture outputTex3D;
    int[] outputTexUID;

    public ComputeShader computeShader;
    int[] kernelUID;

    int wrkgrpCountX;
    int wrkgrpCountY;
    int wrkgrpCountZ;

    Vector4 res;
    int resUID;
    List<ComputeBuffer> propsBuffer;
    List<ComputeBuffer> curveBuffer;
    int[] propsBufferUID;
    int[] curveBufferUID;
    int[] propsBufferSize;
    int[] curveBufferSize;

    public List<Property[]> propsList;
    public List<Vector3> curveList;

    float[] propsData;
    float[] curveData;

    public List<NoiseKitUtil.Node> nodeList;
    
    public class Property
    {
        public string name;
        public float value;
        public float min;
        public float max;

        public Property(string _name, float _val, float _min, float _max)
        {
            value = _val;
            name = _name;
            min = _min;
            max = _max;
        }
    }

    public NoiseGenerator(int resx, int resy, int resz)
    {
        kernelUID = new int[2];
        outputTexUID = new int[2];
        res = new Vector4(resx, resy, resz, 1);
        nodeList = new List<NoiseKitUtil.Node>();
        propsList = new List<Property[]>();
        curveList = new List<Vector3>();

        propsBufferUID = new int[10];
        curveBufferUID = new int[10];

        propsBuffer = new List<ComputeBuffer>();
        curveBuffer = new List<ComputeBuffer>();

        res = new Vector4(res.x, res.y, res.z, 1);

        #if UNITY_EDITOR
            Debug.Log("NoiseKit: Created Noise Generator");
        #endif

        UpdateRT((int)res.x, (int)res.y, (int)res.z, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
    }

    public void SetupNodes(List<NoiseKitUtil.Node> nodes)
    {
        nodeList.Clear(); 
        for(int i=0; i<nodes.Count; i++)
        {
            nodeList.Add(nodes[i]);
        }
    }
    public void SetupCompute(float resx, float resy, float resz)
    {
        res.x = resx;
        res.y = resy;
        res.z = resz;
        kernelUID[0] = computeShader.FindKernel("NoiseKernel2D");
        kernelUID[1] = computeShader.FindKernel("NoiseKernel3D");
        uint workgroupSizeX;
        uint workgroupSizeY;
        uint workgroupSizeZ;
        computeShader.GetKernelThreadGroupSizes(kernelUID[NoiseKitUtil.mode], out workgroupSizeX, out workgroupSizeY, out workgroupSizeZ);

        wrkgrpCountX = (int)(Mathf.Ceil((int)res.x / workgroupSizeX));
        wrkgrpCountY = (int)(Mathf.Ceil((int)res.y / workgroupSizeY));
        wrkgrpCountZ = (int)(Mathf.Ceil((int)res.z / workgroupSizeZ));

        SetupProperties();
        SetupPropsBuffer();
        SetupCurveBuffer();

        propsBufferUID = new int[nodeList.Count];
        curveBufferUID = new int[nodeList.Count];
        for (int i=0; i<nodeList.Count; i++)
        {
            propsBufferUID[i] = Shader.PropertyToID("_propsBuffer"+i.ToString());
            curveBufferUID[i] = Shader.PropertyToID("_curveBuffer"+i.ToString());
        }

        resUID = Shader.PropertyToID("_res");
        outputTexUID[0] = Shader.PropertyToID("_outputTex2D");
        outputTexUID[1] = Shader.PropertyToID("_outputTex3D");
    }

    public void DispatchCompute()
    {
        UpdatePropsBuffer();
        UpdateCurveBuffer();

        for(int i = 0; i < nodeList.Count; i++)
        {
            computeShader.SetBuffer(kernelUID[NoiseKitUtil.mode], propsBufferUID[i], propsBuffer[i]);
            computeShader.SetBuffer(kernelUID[NoiseKitUtil.mode], curveBufferUID[i], curveBuffer[i]);
        }

        computeShader.SetVector(resUID, res);
        if (NoiseKitUtil.mode == 0)
        {
            computeShader.SetTexture(kernelUID[NoiseKitUtil.mode], outputTexUID[NoiseKitUtil.mode], outputTex);
        } else
        {
            computeShader.SetTexture(kernelUID[NoiseKitUtil.mode], outputTexUID[NoiseKitUtil.mode], outputTex3D);
        }
        computeShader.Dispatch(kernelUID[NoiseKitUtil.mode], wrkgrpCountX, wrkgrpCountY, wrkgrpCountZ);
    }
    
    void SetupProperties()
    {
        propsList.Clear();
        int nodeCount = nodeList.Count;
        propsBufferSize = new int[nodeCount];
        curveBufferSize = new int[nodeCount];

        for (int i=0; i<nodeCount; i++)
        {
            Property[] propsArray = new Property[nodeList[i].properties.Count];
            for(int j=0; j<nodeList[i].properties.Count; j++)
            {
                Property prop = new Property(nodeList[i].properties[j].name, nodeList[i].properties[j].val, nodeList[i].properties[j].min, nodeList[i].properties[j].max);
                propsArray[j] = prop;
            }
            propsList.Add(propsArray);
            propsBufferSize[i] = nodeList[i].properties.Count;

            Vector3 cps = new Vector3(0.0f, 0.5f, 1.0f);
            curveList.Add(cps);
            curveBufferSize[i] = 3;
        }
    }

    void SetupPropsBuffer()
    {
        for (int i=0; i<propsBuffer.Count; i++)
        {
            propsBuffer[i].Dispose();
        }
        propsBuffer.Clear();
        for (int i=0; i<propsBufferSize.Length; i++)
        {
            if (i >= propsBuffer.Count)
            {
                ComputeBuffer computeBuffer = new ComputeBuffer(propsBufferSize[i], sizeof(float), ComputeBufferType.Structured);
                propsBuffer.Add(computeBuffer);
            }
            propsData = new float[propsBufferSize[i]];
            for (int j = 0; j < propsList[i].Length; j++)
            {
                propsData[j] = propsList[i][j].value;
            }
            propsBuffer[i].SetData(propsData);
        }
    }

    void SetupCurveBuffer()
    {
        for (int i = 0; i < curveBuffer.Count; i++)
        {
            curveBuffer[i].Dispose();
        }
        curveBuffer.Clear();

        for (int i = 0; i < curveBufferSize.Length; i++)
        {

            curveBufferSize[i] = 3;
            ComputeBuffer computeBuffer = new ComputeBuffer(curveBufferSize[i], sizeof(float), ComputeBufferType.Structured);
            curveBuffer.Add(computeBuffer);
            curveData = new float[3];
            curveData[0] = 0.0f;
            curveData[1] = 0.5f;
            curveData[2] = 1.0f;
            curveBuffer[i].SetData(curveData);
        }
    }

    public void UpdatePropsBuffer()
    {
        for (int i = 0; i < nodeList.Count; i++)
        {
            propsData = new float[propsBufferSize[i]];
            for (int j = 0; j < propsBufferSize[i]; j++)
            {
                propsData[j] = propsList[i][j].value;
            }
            propsBuffer[i].SetData(propsData);
        }
    }

    public void UpdateCurveBuffer()
    {
        for (int i = 0; i < curveBufferSize.Length; i++)
        {
            curveData = new float[curveBufferSize[i]];
            for (int j = 0; j < 3; j++)
            {
                curveData[j] = curveList[i][j];
            }
            curveBuffer[i].SetData(curveData);
        }
    }

    public void UpdateRT(int resx, int resy, int resz, RenderTextureFormat format, RenderTextureReadWrite colorspace)
    {
        res.x = resx;
        res.y = resy;
        res.z = resz;
        outputTex = new RenderTexture((int)res.x, (int)res.y, (int)res.z, format, colorspace);
        outputTex.name = "NoiseEngine_RT";
        outputTex.enableRandomWrite = true;
        outputTex.Create();

        RenderTextureDescriptor rtDesc = new RenderTextureDescriptor((int)res.x, (int)res.y);
        rtDesc.dimension = TextureDimension.Tex3D;
        rtDesc.volumeDepth = (int)res.z;
        rtDesc.colorFormat = format;
        rtDesc.enableRandomWrite = true;
        if (colorspace == RenderTextureReadWrite.sRGB)
        {
            rtDesc.sRGB = true;
        } else
        {
            rtDesc.sRGB = false;
        }
        outputTex3D = new RenderTexture(rtDesc);
        outputTex3D.Create();
    }

    public RenderTexture GetTex()
    {
        if (NoiseKitUtil.mode == 0)
        {
            return outputTex;
        } else
        {
            return outputTex3D;
        }
    }
    ~NoiseGenerator()
    {
        for (int i = 0; i < propsBuffer.Count; i++)
        {
            propsBuffer[i].Dispose();
        }
        for (int i = 0; i < curveBuffer.Count; i++)
        {
            curveBuffer[i].Dispose();
        }
    }

}
